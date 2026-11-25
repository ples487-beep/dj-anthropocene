(function () {
  if (window.game) {
    return;
  }

  var handlers = {};
  var state = { act: 1, flags: [], close_locked: false, navigation_locked: false };

  function emit(type, data) {
    (handlers[type] || []).slice().forEach(function (handler) {
      handler(data);
    });
  }

  var game = {
    state: state,
    ready: false,
    send: function (type, data) {
      window.sendIpcMessage(JSON.stringify({ type: type, data: data === undefined ? null : data }));
    },
    on: function (type, handler) {
      (handlers[type] = handlers[type] || []).push(handler);
      if (type === "state" && game.ready) {
        handler(state);
      }
    },
    has: function (flag) {
      return state.flags.indexOf(flag) !== -1;
    },
    flag: function (flag, value) {
      game.send("flag", { name: flag, value: value !== false });
    },
    glitch: function (duration, strength) {
      game.send("glitch", { duration: duration || 0.6, strength: strength || 1.0 });
    }
  };

  window.ipcMessage.addListener(function (raw) {
    var message;
    try {
      message = JSON.parse(raw);
    } catch (error) {
      message = { type: "message", data: raw };
    }
    if (message.type === "state") {
      Object.assign(state, message.data);
      game.ready = true;
    }
    emit(message.type, message.data);
  });

  document.addEventListener("click", function (event) {
    var link = event.target.closest ? event.target.closest("a[href]") : null;
    if (link && state.navigation_locked) {
      event.preventDefault();
      event.stopPropagation();
      game.send("link_blocked", link.href);
    }
  }, true);

  window.game = game;
})();
