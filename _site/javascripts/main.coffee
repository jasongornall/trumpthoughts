msnry = null
config = {
  apiKey: "AIzaSyBmPkme_3537O_YbLRlq27PiFMOtNi4vP4",
  authDomain: "trump-64059.firebaseapp.com",
  databaseURL: "https://trump-64059.firebaseio.com",
  storageBucket: "trump-64059.appspot.com",
  messagingSenderId: "57700495171"
}
firebase.initializeApp(config);

renderProfile = ->
  $('body > #navigation > .profile').remove()
  if window.logged_in
    $('body > #navigation').prepend teacup.render ->
      a href: '/profile', ->
        span -> "profile: "
        img src: window.logged_in.photoURL
  else
    $('body > #navigation > .profile').remove()
    $('body > #navigation').prepend teacup.render ->
      div '.profile', -> 'Login'
    $('body > #navigation > .profile').on 'click', loginPopup

try
  temp_user = JSON.parse localStorage.getItem('user')
  window.logged_in = temp_user
  renderProfile()

# move cursor
firebase.auth().onAuthStateChanged (user) ->
  try
    if window.logged_in?.uid is user.uid
      return

  if user and window.access_token
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
            'gender'
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
        uid: user.uid or null
        gender: extra_info.gender or null
        facebook_id: user.providerData[0].uid or null
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
      localStorage.setItem('user', JSON.stringify window.logged_in)
      firebase.database().ref("users/#{user.uid}/data").set window.logged_in
      renderProfile()
  else
    window.logged_in = false
    localStorage.removeItem('user')
    renderProfile()


handleLink = ->
  console.log 'saddasdsa'
  $('a').off('click').on 'click', (e) ->
    e.preventDefault();
    $el = $ e.currentTarget
    href = $el.attr 'href'
    path = url 'path', href
    route_url(path or '/')
    render()
    console.log 'eh?'
    return false

getLetter = (u_snap, l_snap, response_type) ->
  uid = l_snap.child('uid').val()

  teacup.render ->
    div ".response #{response_type}", ->
      div '.user-header', ->
        img src: u_snap.child('photoURL').val()
        div '.user', ->
          a '.name', href: "/users/#{uid}", ->
            u_snap.child('displayName').val()
          div '.time', -> jQuery.timeago l_snap.child('time').val()
      a '.link.letter', href: "/#{response_type}/#{l_snap.key}", ->
        i '.fa fa-link', -> ''
      a '.link.back', href: "/", ->
        i '.fa fa-arrow-left', -> ''
      if window.logged_in.uid is uid
        a '.link.edit', href: "/edit/#{response_type}/#{l_snap.key}", ->
          i '.fa fa-pencil', -> ''

      div '.body', -> l_snap.child('letter').val()

      div '.footer', ->
        span -> '* Edited' if l_snap.child('edited').val()

RESPONSE_ARR = ['negative', 'positive']
RESPONSE_LISTEN = 'child_added'

route_url = (path)->
  for listener in window.listeners or []
    listener.off()
  window.listeners = []

  window.apply_filter = (ref) ->
    return ref

  $('body').attr('class','')
  console.log 'path', path
  path = path || url 'path'

  data = path.split('/')
  history.replaceState(null, null, path);

  new_path = "/#{data[1]}"

  RESPONSE_ARR = ['negative', 'positive']
  RESPONSE_LISTEN = 'child_added'
  $("#negative, #positive").empty()

  console.log new_path, 'new_path'
  switch new_path

    when '/profile'
      $('[data-route]').hide()
      $el = $("[data-route='/profile']")
      $('#logout').off('click').on 'click', (e) ->
        localStorage.clear()
        window.location = url('hostname')
      $el.fadeIn()
      window.apply_filter = (ref) ->
        return ref.orderByChild('uid').equalTo(window.logged_in.uid)

      $("[data-route='/']").show()

    when '/edit'
      $el = $("[data-route='/new-letter']")
      $el.hide()
      $el.addClass "#{data[2]}"
      $el.attr 'data-save', "#{data[2]}/#{data[3]}"
      RESPONSE_ARR = []
      firebase.database().ref("#{data[2]}/#{data[3]}").once 'value', (snap) ->
        $('#trump-letter').val snap.child('letter').val()
        $el.fadeIn()

    when '/new-letter'
      $el = $("[data-route='/new-letter']")
      $el.attr 'class', ''
      $el.attr 'data-save', ''
      $('#trump-letter').val 'Dear Trump'
      $("[data-route='#{new_path}']").fadeIn()
      RESPONSE_ARR = []

    when '/positive', '/negative'
      $('[data-route]').hide()

      RESPONSE_ARR = ["#{data[1]}/#{data[2]}"]
      RESPONSE_LISTEN = 'value'
      console.log 'inside'
      new_path = '/'
      $('[data-route]').hide()
      $("body").addClass 'big'
      $("[data-route='#{new_path}']").show()
    else
      new_path = '/'
      $('[data-route]').hide()
      $("[data-route='#{new_path}']").show()


softClose = (e) ->
  $(e.currentTarget).closest('.modalDialog').fadeOut 'slow'

handleClose = (e) ->
  $el = $(e.currentTarget).closest('.modalDialog').fadeOut 'slow', ->
    $(this).remove()

loginPopup = (next) ->
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

$('.modalDialog.letter .close').on 'click', softClose

$('.submit').on 'click', (e) ->
  $el = $ e.currentTarget
  type = $el.data 'type'
  if window.logged_in
    trump_letter = $('#trump-letter').val()

    edited = null
    save = $el.closest('.letter').data 'save'
    if save
      save_data = save.split('/')
      if save_data[0] isnt type
        firebase.database().ref("users/#{window.logged_in.uid}/#{save}").remove()
        firebase.database().ref(save).remove()
        save = "#{type}/#{save_data[1]}"
      ref = firebase.database().ref(save)
      edited = true
    else
      ref = firebase.database().ref(type).push()

    async.parallel [

      (next) ->
        obj = {
          letter: trump_letter.trim()
          time: firebase.database.ServerValue.TIMESTAMP
          uid: window.logged_in.uid
        }
        if edited
          obj.edited = firebase.database.ServerValue.TIMESTAMP
        else
          obj.time = firebase.database.ServerValue.TIMESTAMP
        ref.setWithPriority obj, 0 - Date.now(), next

      (next) ->
        firebase.database().ref("users/#{window.logged_in.uid}/data/last_submit").set firebase.database.ServerValue.TIMESTAMP, next
    ], ->
      route_url("/#{type}/#{ref.key}")
      render()
  else
    loginPopup()


render = ->
  uluru =  {
    lat: -25.363
    lng: 131.044
  }
  $('#map').empty()
  window.map = new google.maps.Map $('#map')[0], {
    zoom: 2
    center: uluru
   }

  interval_id = null
  interval_arr = []
  pushMarker = (func)->
    console.trace('wakka')
    interval_arr.push func
    if interval_id is null
      interval_id = setInterval ( ->
        if interval_arr.length is 0
          clearInterval interval_id
          interval_id = null
        else
          interval_arr.pop()()
      ), 100


  for response_type in RESPONSE_ARR
    do (response_type) ->
      mod_res = response_type.split('/')[0]

      listen_ref = firebase.database().ref(response_type)
      window.listeners.push listen_ref

      listen_ref = window.apply_filter listen_ref
      listen_ref.limitToLast(200).on RESPONSE_LISTEN, (snapshot) ->
        uid = snapshot.child('uid').val()

        firebase.database().ref("users/#{uid}/data").once 'value', (user_snap) ->
          lat = user_snap.child('lat').val()
          lng = user_snap.child('lng').val()
          pushMarker ->
            latLng = {lat: lat + Math.random() * 20, lng: lng + Math.random() * 20}
            marker = new google.maps.Marker {
              position: latLng,
              map: window.map
              animation: google.maps.Animation.DROP
              zoom: 3
            }
            window.map.panTo(latLng);

          console.log user_snap, snapshot, mod_res
          letter = getLetter(user_snap, snapshot, mod_res)
          $(letter).prependTo("##{mod_res}").hide().slideDown();
          handleLink()

route_url()
render()

