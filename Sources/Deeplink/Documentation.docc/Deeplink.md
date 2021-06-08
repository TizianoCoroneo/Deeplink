# ``Deeplink``

A microlibrary to parse deeplinks and their arguments.

## Overview

To support deeplinking in your app you just need to follow these steps:

- Define the data you want to parse as simple `struct`s.
- Define the deeplink templates that you want to support using the ``Deeplink`` object.
- Register behaviors for each template using the ``DeeplinksCenter`` `register` methods.
- You're ready to parse URLs now 🙌! Follow the tutorial for more details and examples.

When parsing a URL, the parameter is associated with the KeyPath that occupies the same location in the URL: if the match is successful, the value of the parameter will be assigned to an instance of the Deeplink's `Value` type, to the corresponding keypath.

![How data goes from inside the URL to inside your model object](ExampleParsing)

## Topics

### Essentials

- <doc:Getting-started-with-Deeplinking>
- ``Deeplink/Deeplink``
- ``Deeplink/DeeplinksCenter``

### Utility

- ``Deeplink/DefaultInitializable``

### Implementation details

- ``Deeplink/AnyDeeplink``
- ``Deeplink/DeeplinkInterpolation``

### Tutorial

- <doc:Tutorial-Table-of-Contents>
