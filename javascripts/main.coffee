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
$('trix-editor')[0].editor.setSelectedRange([100, 100])

firebase.auth().onAuthStateChanged (user) ->
  $('body > #auth').html teacup.render ->
    div  '.btn', ->
      span -> "logged in as: "
      img src: user.photoURL
      span -> " #{user.displayName}"


$('#submit').on 'click', (obj) ->
  $('body #popups').append(teacup.render ->
    div '.modalDialog submit', ->
      div '.wrapper', ->
        span '.close', -> 'x'
        h3 -> 'Login to add your content'
        div '.navigation', ->
          span '.option', 'data-option': 'google', ->
            img src: 'https://www.gstatic.com/mobilesdk/160512_mobilesdk/auth_service_google.svg'
            span -> 'Google'
          span '.option', 'data-option': 'facebook', ->
            img src: 'https://www.gstatic.com/mobilesdk/160409_mobilesdk/images/auth_service_facebook.svg'
            span -> 'Facebook'
          span '.option', 'data-option': 'twitter', ->
            img src: 'https://www.gstatic.com/mobilesdk/160409_mobilesdk/images/auth_service_twitter.svg'
            span -> 'Twitter'
  )
  $('.modalDialog.submit').fadeIn()
  $('.modalDialog.submit .close').on 'click', (e) ->
    $el = $(e.currentTarget).closest('.modalDialog').fadeOut 'slow', ->
      $(this).remove()

  $('.modalDialog.submit [data-option]').on 'click', (e) ->
    $el = $ e.currentTarget
    switch $el.data 'option'
      when 'google'
        provider = new firebase.auth.GoogleAuthProvider();
        firebase.auth().signInWithPopup(provider).then((result) ->
          token = result.credential.accessToken
          user = result.user
          finishLogin(token, user)
        ).catch (error) ->
          console.log error if error
