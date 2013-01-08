# Quarter Spiral Game Developer SDK

This SDK is the interface between your game and the Quarter Spiral platform. It's platform independent so that you can use the same tools and API no matter if you are developing flash or HTML5 games.

## HTML5

### Setup

Include this ``script`` tag on every page you want to use the SDK from:

```html
<script src="http://sdk-app.herokuapp.com/javascripts/sdk.js" type="text/javascript"></script>
```

Now initialize the SDK in your JavaScript:

```javascript
QS.setup().then(function (qs) {
    …
})
```

Inside of that function you now have access to the ``qs`` objects which comes with some nifty helpers to make your life easier.

**Make sure to call ``QS.setup`` only once on every page!**

If a player is not logged in when playing the game (e.g. when playing through an embed on a third party website) the SDK will not setup! It will reject the promise. Handle that case like this:

```javascript
QS.setup().then(function (qs) {
  // success!
}, function(error) {
  // Not setup. Log the reason:
  console.log(error.message)
})
```

### Retrieve information about the player

```javascript
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

## Flash

**The Flash SDK is in in a raw state at the moment. Please pay additional caution when using it!**

### Setup

Import these packages:

```actionscript
import flash.display.LoaderInfo;
import flash.external.ExternalInterface;
import flash.system.Security;
```

Then make sure to allow communication with QS:

```actionscript
var flashVars:Object = LoaderInfo(this.root.loaderInfo).parameters;

flash.system.Security.allowInsecureDomain(flashVars.qsCanvasHost)
flash.system.Security.allowDomain(flashVars.qsCanvasHost)
```

Once the QS initialization is done, the SDK will reach out to a special callback. Register it like this:

```actionscript
function qsSetupCallback(qs):void {
  // QS SDK ready!
}
ExternalInterface.addCallback('qsSetupCallback', qsSetupCallback);
```

Now you got to initialize the QS SDK with:

```actionscript
ExternalInterface.call('QS.setup')
```

**Make sure to call ``QS.setup`` only once!**

Once that callback was called you have access to the full QS functionality.

If a player is not logged in when playing the game (e.g. when playing through an embed on a third party website) the SDK will not setup! It will instead call an error callback. You can register it like this:

```actionscript
function qsSetupErrorCallback(message):void {
  // QS SDK not ready! Reason can be found in the message variable
}
ExternalInterface.addCallback('qsSetupErrorCallback', qsSetupErrorCallback);
```

### Retrieve information about the player

First register the callback to retrieve the info about the player or errors in case they happen:

```actionscript
function qsPlayerInfoCallback(player):void {
  trace("Player info loaded");
  trace(player.name);
  trace(player.email);
}
ExternalInterface.addCallback('qsPlayerInfoCallback', qsPlayerInfoCallback);

function qsPlayerInfoErrorCallback(message):void {
  //An error has happened!
}
ExternalInterface.addCallback('qsPlayerInfoErrorCallback', qsPlayerInfoErrorCallback);
```

Then call ``QS.flash.retrievePlayerInfo`` to trigger the retrieval of the information:

```actionscript
function qsSetupCallback(qs):void {
  ExternalInterface.call('QS.flash.retrievePlayerInfo')
}
ExternalInterface.addCallback('qsSetupCallback', qsSetupCallback);

ExternalInterface.call('QS.setup')
```

The ``retrievePlayerInfo`` call gives you a player object that holds information about the currently logged in player. You can access it's ``name``, ``email`` and ``uuid`` which is it's unique identifier within the Quarter Spiral universe.

In some cases an email address might not be present. For the time being we return ``unknown@example.com`` in these cases but this will be subject to change.

### Manage player data

Quarter Spiral lets you save data for every player that plays your game.

```actionscript
function qsSetupCallback(qs):void {
  ExternalInterface.call('QS.flash.setPlayerData', {
    highScore: 190,
    tutorialCompleted: true
  })
}
ExternalInterface.addCallback('qsSetupCallback', qsSetupCallback);

ExternalInterface.call('QS.setup')
```

This call will overwrite all data that was previously stored for this player. If you only want to adjust a single value you can do that:

```javascript
function qsSetupCallback(qs):void {
  ExternalInterface.call('QS.flash.setPlayerData', 'highScore', 190);
}
ExternalInterface.addCallback('qsSetupCallback', qsSetupCallback);

ExternalInterface.call('QS.setup')
```

To know if the data could be saved or an error have occurred there are two callbacks you can register:

```actionscript
function qsPlayerDataSetCallback(data):void {
  //Data was saved and the complete data is passed in in the data variable.
  //Please note that even if you only set a single value the data variable always holds the complete data!
}
ExternalInterface.addCallback('qsPlayerDataSetCallback', qsPlayerDataSetCallback);

function qsPlayerDataSetErrorCallback(message):void {
  trace("Problem setting player data:: " + message)
}
ExternalInterface.addCallback('qsPlayerDataSetErrorCallback', qsPlayerDataSetErrorCallback);
```

There is also a convenient way to retrieve the current player's data:

```actionscript
function qsPlayerDataCallback(data):void {
  trace("Player data loaded!")
}
ExternalInterface.addCallback('qsPlayerDataCallback', qsPlayerDataCallback);
 
function qsPlayerDataErrorCallback(message):void {
  trace("Problem loading player data: " + message)
}
ExternalInterface.addCallback('qsPlayerDataErrorCallback', qsPlayerDataErrorCallback);

function qsSetupCallback(qs):void {
  ExternalInterface.call('QS.flash.retrievePlayerData')
}
ExternalInterface.call('QS.setup')
```

