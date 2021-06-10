# ``Deeplink/DeeplinksCenter``

Register deeplinks and parse URLs.

@Metadata {
    @DocumentationExtension(mergeBehavior: override)
}

## Overview

The ``DeeplinksCenter`` is the object you use to register behaviors for your ``Deeplink/Deeplink`` templates: when a template matches the URL you're parsing, the `ifMatching` closure on the `register` method is triggered.

Then, you can use the `parse` method to attempt matching a URL against the list of registered deeplink templates you built.

## Topics

### Initialize a center

- ``init()``
- ``init(_:)``

### Registering deeplinks

- ``register(deeplink:assigningTo:ifMatching:)``
- ``register(deeplink:ifMatching:)``
- ``register(deeplinks:assigningTo:ifMatching:)``
- ``register(deeplinks:ifMatching:)``

### Parsing URLs

- ``parse(url:)``
