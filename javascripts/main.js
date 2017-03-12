// Generated by CoffeeScript 1.8.0
var RESPONSE_ARR, RESPONSE_LISTEN, config, getLetter, handleClose, handleLink, loginPopup, msnry, render, renderProfile, route_url, softClose, temp_user;

msnry = null;

config = {
  apiKey: "AIzaSyBmPkme_3537O_YbLRlq27PiFMOtNi4vP4",
  authDomain: "trump-64059.firebaseapp.com",
  databaseURL: "https://trump-64059.firebaseio.com",
  storageBucket: "trump-64059.appspot.com",
  messagingSenderId: "57700495171"
};

firebase.initializeApp(config);

renderProfile = function() {
  $('body > #navigation > .profile').remove();
  if (window.logged_in) {
    return $('body > #navigation').prepend(teacup.render(function() {
      return a({
        href: '/profile'
      }, function() {
        span(function() {
          return "profile: ";
        });
        return img({
          src: window.logged_in.photoURL
        });
      });
    }));
  } else {
    $('body > #navigation > .profile').remove();
    $('body > #navigation').prepend(teacup.render(function() {
      return div('.profile', function() {
        return 'Login';
      });
    }));
    return $('body > #navigation > .profile').on('click', loginPopup);
  }
};

try {
  temp_user = JSON.parse(localStorage.getItem('user'));
  window.logged_in = temp_user;
  renderProfile();
} catch (_error) {}

firebase.auth().onAuthStateChanged(function(user) {
  var _ref;
  try {
    if (((_ref = window.logged_in) != null ? _ref.uid : void 0) === user.uid) {
      return;
    }
  } catch (_error) {}
  if (user && window.access_token) {
    return async.waterfall([
      (function(_this) {
        return function(finish) {
          var k, params, url, v;
          params = ((function() {
            var _ref1, _results;
            _ref1 = {
              access_token: window.access_token,
              fields: ['about', 'birthday', 'location', 'education', 'relationship_status', 'religion', 'political', 'gender'].join(','),
              format: 'json',
              method: 'get',
              suppress_http_code: '1'
            };
            _results = [];
            for (k in _ref1) {
              v = _ref1[k];
              _results.push("" + k + "=" + (encodeURIComponent(v)));
            }
            return _results;
          })()).join('&');
          url = "https://graph.facebook.com/v1.0/me?" + params;
          return $.get(url, function(extra_info) {
            return finish(null, extra_info);
          });
        };
      })(this), (function(_this) {
        return function(extra_info, finish) {
          var k, params, url, v;
          params = ((function() {
            var _ref1, _results;
            _ref1 = {
              access_token: window.access_token,
              fields: 'location',
              format: 'json',
              method: 'get',
              suppress_http_code: '1'
            };
            _results = [];
            for (k in _ref1) {
              v = _ref1[k];
              _results.push("" + k + "=" + (encodeURIComponent(v)));
            }
            return _results;
          })()).join('&');
          url = "https://graph.facebook.com/" + extra_info.location.id + "?" + params;
          return $.get(url, function(extra_info_location) {
            extra_info.location = extra_info_location.location;
            return finish(null, extra_info);
          });
        };
      })(this)
    ], function(err, extra_info) {
      window.logged_in = {
        displayName: user.displayName || null,
        email: user.email || null,
        photoURL: user.photoURL || null,
        uid: user.uid || null,
        gender: extra_info.gender || null,
        facebook_id: user.providerData[0].uid || null,
        birthday: extra_info.birthday || null,
        city: extra_info.location.city || null,
        country: extra_info.location.country || null,
        state: extra_info.location.state || null,
        lat: extra_info.location.latitude || null,
        lng: extra_info.location.longitude || null,
        education: extra_info.education || null,
        political: extra_info.political || null,
        relationship_status: extra_info.relationship_status || null
      };
      localStorage.setItem('user', JSON.stringify(window.logged_in));
      firebase.database().ref("users/" + user.uid + "/data").set(window.logged_in);
      return renderProfile();
    });
  } else {
    window.logged_in = false;
    localStorage.removeItem('user');
    return renderProfile();
  }
});

handleLink = function() {
  console.log('saddasdsa');
  return $('a').off('click').on('click', function(e) {
    var $el, href, path;
    e.preventDefault();
    $el = $(e.currentTarget);
    href = $el.attr('href');
    path = url('path', href);
    route_url(path || '/');
    render();
    console.log('eh?');
    return false;
  });
};

getLetter = function(u_snap, l_snap, response_type) {
  var uid;
  uid = l_snap.child('uid').val();
  return teacup.render(function() {
    return div(".response " + response_type, function() {
      div('.user-header', function() {
        img({
          src: u_snap.child('photoURL').val()
        });
        return div('.user', function() {
          a('.name', {
            href: "/users/" + uid
          }, function() {
            return u_snap.child('displayName').val();
          });
          return div('.time', function() {
            return jQuery.timeago(l_snap.child('time').val());
          });
        });
      });
      a('.link.letter', {
        href: "/" + response_type + "/" + l_snap.key
      }, function() {
        return i('.fa fa-link', function() {
          return '';
        });
      });
      a('.link.back', {
        href: "/"
      }, function() {
        return i('.fa fa-arrow-left', function() {
          return '';
        });
      });
      if (window.logged_in.uid === uid) {
        a('.link.edit', {
          href: "/edit/" + response_type + "/" + l_snap.key
        }, function() {
          return i('.fa fa-pencil', function() {
            return '';
          });
        });
      }
      div('.body', function() {
        return l_snap.child('letter').val();
      });
      return div('.footer', function() {
        return span(function() {
          if (l_snap.child('edited').val()) {
            return '* Edited';
          }
        });
      });
    });
  });
};

RESPONSE_ARR = ['negative', 'positive'];

RESPONSE_LISTEN = 'child_added';

route_url = function(path) {
  var $el, data, listener, new_path, _i, _len, _ref;
  _ref = window.listeners || [];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    listener = _ref[_i];
    listener.off();
  }
  window.listeners = [];
  window.apply_filter = function(ref) {
    return ref;
  };
  $('body').attr('class', '');
  console.log('path', path);
  path = path || url('path');
  data = path.split('/');
  history.replaceState(null, null, path);
  new_path = "/" + data[1];
  RESPONSE_ARR = ['negative', 'positive'];
  RESPONSE_LISTEN = 'child_added';
  $("#negative, #positive").empty();
  console.log(new_path, 'new_path');
  switch (new_path) {
    case '/profile':
      $('[data-route]').hide();
      $el = $("[data-route='/profile']");
      $('#logout').off('click').on('click', function(e) {
        localStorage.clear();
        return window.location = url('hostname');
      });
      $el.fadeIn();
      window.apply_filter = function(ref) {
        return ref.orderByChild('uid').equalTo(window.logged_in.uid);
      };
      return $("[data-route='/']").show();
    case '/edit':
      $el = $("[data-route='/new-letter']");
      $el.hide();
      $el.addClass("" + data[2]);
      $el.attr('data-save', "" + data[2] + "/" + data[3]);
      RESPONSE_ARR = [];
      return firebase.database().ref("" + data[2] + "/" + data[3]).once('value', function(snap) {
        $('#trump-letter').val(snap.child('letter').val());
        return $el.fadeIn();
      });
    case '/new-letter':
      $("[data-route='" + new_path + "']").fadeIn();
      return RESPONSE_ARR = [];
    case '/positive':
    case '/negative':
      $('[data-route]').hide();
      RESPONSE_ARR = ["" + data[1] + "/" + data[2]];
      RESPONSE_LISTEN = 'value';
      console.log('inside');
      new_path = '/';
      $('[data-route]').hide();
      $("body").addClass('big');
      return $("[data-route='" + new_path + "']").show();
    default:
      new_path = '/';
      $('[data-route]').hide();
      return $("[data-route='" + new_path + "']").show();
  }
};

softClose = function(e) {
  return $(e.currentTarget).closest('.modalDialog').fadeOut('slow');
};

handleClose = function(e) {
  var $el;
  return $el = $(e.currentTarget).closest('.modalDialog').fadeOut('slow', function() {
    return $(this).remove();
  });
};

loginPopup = function(next) {
  $('body #popups').append(teacup.render(function() {
    return div('.modalDialog submit', function() {
      return div('.wrapper', function() {
        span('.close', function() {
          return 'x';
        });
        h3(function() {
          return 'Login to add your content';
        });
        return div('.navigation', function() {
          return span('.option', {
            'data-option': 'facebook'
          }, function() {
            img({
              src: 'https://www.gstatic.com/mobilesdk/160409_mobilesdk/images/auth_service_facebook.svg'
            });
            return span(function() {
              return 'Facebook';
            });
          });
        });
      });
    });
  }));
  $('.modalDialog.submit').fadeIn();
  $('.modalDialog.submit .close').on('click', handleClose);
  return $('.modalDialog.submit [data-option]').on('click', function(e) {
    var $el, item, provider, _i, _len, _ref;
    $el = $(e.currentTarget);
    switch ($el.data('option')) {
      case 'facebook':
        provider = new firebase.auth.FacebookAuthProvider();
        _ref = ['user_birthday', 'public_profile', 'email', 'user_location', 'user_relationships', 'user_relationship_details', 'user_education_history', 'user_religion_politics'];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          item = _ref[_i];
          provider.addScope(item);
        }
        firebase.auth().signInWithPopup(provider).then(function(result) {
          var user;
          window.access_token = result.credential.accessToken;
          return user = result.user;
        });
        return handleClose(e);
    }
  });
};

$('#voice').on('click', function(e) {
  return route_url('/new-letter');
});

$('.modalDialog.letter .close').on('click', softClose);

$('.submit').on('click', function(e) {
  var $el, edited, ref, save, save_data, trump_letter, type;
  $el = $(e.currentTarget);
  type = $el.data('type');
  if (window.logged_in) {
    trump_letter = $('#trump-letter').val();
    edited = null;
    save = $el.closest('.letter').data('save');
    if (save) {
      save_data = save.split('/');
      if (save_data[0] !== type) {
        firebase.database().ref("users/" + window.logged_in.uid + "/" + save).remove();
        firebase.database().ref(save).remove();
        save = "" + type + "/" + save_data[1];
      }
      ref = firebase.database().ref(save);
      edited = true;
    } else {
      ref = firebase.database().ref(type).push();
    }
    return async.parallel([
      function(next) {
        var obj;
        obj = {
          letter: trump_letter.trim(),
          time: firebase.database.ServerValue.TIMESTAMP,
          uid: window.logged_in.uid
        };
        if (edited) {
          obj.edited = firebase.database.ServerValue.TIMESTAMP;
        } else {
          obj.time = firebase.database.ServerValue.TIMESTAMP;
        }
        return ref.setWithPriority(obj, 0 - Date.now(), next);
      }, function(next) {
        return firebase.database().ref("users/" + window.logged_in.uid + "/data/last_submit").set(firebase.database.ServerValue.TIMESTAMP, next);
      }
    ], function() {
      route_url("/" + type + "/" + ref.key);
      return render();
    });
  } else {
    return loginPopup();
  }
});

render = function() {
  var interval_arr, interval_id, pushMarker, response_type, uluru, _i, _len, _results;
  uluru = {
    lat: -25.363,
    lng: 131.044
  };
  $('#map').empty();
  window.map = new google.maps.Map($('#map')[0], {
    zoom: 2,
    center: uluru
  });
  interval_id = null;
  interval_arr = [];
  pushMarker = function(func) {
    console.trace('wakka');
    interval_arr.push(func);
    if (interval_id === null) {
      return interval_id = setInterval((function() {
        if (interval_arr.length === 0) {
          clearInterval(interval_id);
          return interval_id = null;
        } else {
          return interval_arr.pop()();
        }
      }), 100);
    }
  };
  _results = [];
  for (_i = 0, _len = RESPONSE_ARR.length; _i < _len; _i++) {
    response_type = RESPONSE_ARR[_i];
    _results.push((function(response_type) {
      var listen_ref, mod_res;
      mod_res = response_type.split('/')[0];
      listen_ref = firebase.database().ref(response_type);
      window.listeners.push(listen_ref);
      listen_ref = window.apply_filter(listen_ref);
      return listen_ref.limitToLast(200).on(RESPONSE_LISTEN, function(snapshot) {
        var uid;
        uid = snapshot.child('uid').val();
        return firebase.database().ref("users/" + uid + "/data").once('value', function(user_snap) {
          var lat, letter, lng;
          lat = user_snap.child('lat').val();
          lng = user_snap.child('lng').val();
          pushMarker(function() {
            var latLng, marker;
            latLng = {
              lat: lat + Math.random() * 20,
              lng: lng + Math.random() * 20
            };
            marker = new google.maps.Marker({
              position: latLng,
              map: window.map,
              animation: google.maps.Animation.DROP,
              zoom: 3
            });
            return window.map.panTo(latLng);
          });
          console.log(user_snap, snapshot, mod_res);
          letter = getLetter(user_snap, snapshot, mod_res);
          $(letter).prependTo("#" + mod_res).hide().slideDown();
          return handleLink();
        });
      });
    })(response_type));
  }
  return _results;
};

route_url();

render();
