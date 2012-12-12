# Quarter Spiral Game Developer SDK

This SDK is the interface between your game and the Quarter Spiral platform. It's platform independent so that you can use the same tools and API no matter if you are developing flash or HTML5 games. Just make sure to follow the embedding instructions below which still depend on the tech of your game.

## Embedding

### HTML5

Include this ``script`` tag on every page you want to use the SDK from:

```html
<script src="http://sdk-app.herokuapp.com/javascripts/sdk.js" type="text/javascript"></script>
```

### Flash

tbd

## Getting started

First thing to do is initializing the SDK in your JavaScript:

```javsacript
QS.setup().then(function (qs) {
    …
})
```

Inside of that function you now have access to the ``qs`` objects which comes with some nifty helpers to make your life easier.

**Make sure to call ``QS.setup`` only once on every page!**

### Retrieve information about the player

```javsacript
QS.setup().then(function (qs) {
  qs.retrievePlayerInfo().then(function (player) {
    console.log("Current player:")
    console.log("Name", player.name)
    console.log("Email", player.email)
  }
})
```

The ``retrievePlayerInfo`` call gives you a player object that holds information about the currently logged in player. You can access it's ``name``, ``email`` and ``uuid`` which is it's unique identifier within the Quarter Spiral universe.

In some cases an email address might not be present. For the time being we return ``unknown@example.com`` in these cases but this will be subject to change.

### Manage player data

Quarter Spiral lets you save data for every player that plays your game.

```javascript
QS.setup().then(function (qs) {
  qs.setPlayerData(
    {tutorialPlayed: true, highScore: 105}
  ).then(function (data) {
    console.log("Player data saved.")
    console.log("Saved data:", data)
  })
})
```

This call will overwrite all data that was previously stored for this player. If you only want to adjust a single value you can do that:

```javascript
QS.setup().then(function (qs) {
  qs.setPlayerData('highScore', 120).then(function (data) {
    console.log("Player data saved.")
    console.log("Saved data:", data)
  })
})
```

Even of you only set a single value you will always get back the full set of stored data for that player in the ``then`` phase.

There is also a convenient way to retrieve the current player's data:

```javascript
QS.setup().then(function (qs) {
  qs.retrievePlayerData().then(function (data) {
    console.log("Player data loaded:", data)
  })
})
```