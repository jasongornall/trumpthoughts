localStorage.clear()
msnry = null
config = {
  apiKey: "AIzaSyBmPkme_3537O_YbLRlq27PiFMOtNi4vP4",
  authDomain: "trump-64059.firebaseapp.com",
  databaseURL: "https://trump-64059.firebaseio.com",
  storageBucket: "trump-64059.appspot.com",
  messagingSenderId: "57700495171"
}
firebase.initializeApp(config);

# move cursor
firebase.auth().onAuthStateChanged (user) ->
  if user
    async.waterfall [
      (finish) =>
        params = ("#{k}=#{encodeURIComponent v}" for k, v of {
          access_token: window.access_token
          fields: [
            'about'
            'birthday'
            'location'
            'education'
            'relationship_status'
            'religion'
            'political'
          ].join ','
          format: 'json'
          method: 'get'
          suppress_http_code: '1'
        }).join '&'

        url = "https://graph.facebook.com/v1.0/me?#{params}"
        $.get url, (extra_info) ->
          finish null, extra_info

      (extra_info, finish) =>
        params = ("#{k}=#{encodeURIComponent v}" for k, v of {
          access_token: window.access_token
          fields: 'location'
          format: 'json'
          method: 'get'
          suppress_http_code: '1'
        }).join '&'

        url = "https://graph.facebook.com/#{extra_info.location.id}?#{params}"
        $.get url, (extra_info_location) ->
          extra_info.location = extra_info_location.location
          finish null, extra_info
    ], (err, extra_info) ->
      window.logged_in = {
        displayName: user.displayName or null
        email: user.email or null
        photoURL: user.photoURL or null
        uid: user.providerData[0].uid or null
        location: extra_info.location.name or null
        birthday: extra_info.birthday or null
        city: extra_info.location.city or null
        country: extra_info.location.country or null
        state: extra_info.location.state or null
        lat: extra_info.location.latitude or null
        lng: extra_info.location.longitude or null
        education: extra_info.education or null
        political: extra_info.political or null
        relationship_status: extra_info.relationship_status or null
      }
      firebase.database().ref("users/#{user.uid}/data").set window.logged_in
      $('body > #auth').html teacup.render ->
        div  '.btn', ->
          span -> "logged in as: "
          img src: user.photoURL
          span -> " #{user.displayName}"
  else
    window.logged_in = false

route_url = (path)->
  path = path || url 'path'
  $('[data-route]').hide()
  $("[data-route='#{path}']").show()
  history.replaceState(null, null, path);

handleClose = (e) ->
  $el = $(e.currentTarget).closest('.modalDialog').fadeOut 'slow', ->
    $(this).remove()

loginPopup = ->
  $('body #popups').append(teacup.render ->
    div '.modalDialog submit', ->
      div '.wrapper', ->
        span '.close', -> 'x'
        h3 -> 'Login to add your content'
        div '.navigation', ->
          span '.option', 'data-option': 'facebook', ->
            img src: 'https://www.gstatic.com/mobilesdk/160409_mobilesdk/images/auth_service_facebook.svg'
            span -> 'Facebook'
  )
  $('.modalDialog.submit').fadeIn()
  $('.modalDialog.submit .close').on 'click', handleClose

  $('.modalDialog.submit [data-option]').on 'click', (e) ->
    $el = $ e.currentTarget

    switch $el.data 'option'
      when 'facebook'
        provider = new firebase.auth.FacebookAuthProvider();

        for item in [
          'user_birthday'
          'public_profile'
          'email'
          'user_location'
          'user_relationships'
          'user_relationship_details'
          'user_education_history'
          'user_religion_politics'
        ]
          provider.addScope(item)

        firebase.auth().signInWithPopup(provider).then (result) ->
          window.access_token = result.credential.accessToken;
          user = result.user;
        handleClose e

$('#voice').on 'click', (e) ->
  route_url '/new-letter'

$('.submit').on 'click', (e) ->
  $el = $ e.currentTarget
  type = $el.data 'type'
  if window.logged_in
    trump_letter = $('#trump-letter').val()

    ref = firebase.database().ref(type).push()
    ref.set {
      letter: trump_letter
      time: firebase.database.ServerValue.TIMESTAMP
      uid: window.logged_in.uid
      geo: {
        lat: window.logged_in.lat
        lng: window.logged_in.lng
      }
    }
    firebase.database().ref("users/#{window.logged_in.uid}/letters").push {
      letter: trump_letter
      location: ref.toString()
    }
  else
    loginPopup()



for response_type in ['negative', 'positive']
  do (response_type) ->
    firebase.database().ref(response_type).on 'child_added', (snapshot) ->

      lat = snapshot.child('geo/lat').val()
      lng = snapshot.child('geo/lng').val()
      if lat and lng
        marker = new google.maps.Marker {
          position:  {lat: lat, lng: lng},
          map: window.map
          animation: google.maps.Animation.DROP
        }

      $(teacup.render ->
        div ".response #{response_type}", 'data': {
          key: snapshot.key
          time: snapshot.child('time').val()
        }, ->
          div '.body', -> snapshot.child('letter').val()
      ).prependTo("##{response_type}").hide().slideDown();

