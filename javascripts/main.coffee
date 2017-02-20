msnry = null
ref = new Firebase "https://trump-64059.firebaseio.com/"

# move cursor
$('trix-editor')[0].editor.setSelectedRange([100, 100])


$('#submit').on 'click', (obj) ->
  $('body #popups').append(teacup.render ->
    div '.modalDialog submit', ->
      div '.wrapper', ->
        span '.close', -> 'x'
        h3 -> 'Pick your submission type'
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

        div '.login', 'data-option': 'login', ->
          h3 -> 'Login via email'

          div ->
            div -> 'email'
            input '.user-name'
          div ->
            div -> 'password'
            input '.password'
          div '.fixed', ->
            div '.btn', -> 'login'

        div '.signup', 'data-option': 'signup', ->
          h3 -> 'Signup via email'
          div ->
            div -> 'email'
            input '.user-name'
          div ->
            div -> 'password'
            input '.password'
          div ->
            div -> 'password (again)'
            input '.password'
          div '.fixed', ->
            div '.btn', -> 'signup'
  )
  $('.modalDialog.submit').fadeIn()
  $('.modalDialog.submit .close').on 'click', (e) ->
    $el = $(e.currentTarget).closest('.modalDialog').fadeOut 'slow', ->
      $(this).remove()
