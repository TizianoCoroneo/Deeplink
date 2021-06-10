//
//  DefaultInitializable.swift
//  
//
//  Created by Tiziano Coroneo on 22/01/2021.
//

/// A protocol which only requirement is an empty initializer.
///
/// This is used by the library to create an empty instance of the `Value` type of a ``Deeplink/Deeplink`` template. In case of successful match between the template and deeplink `URL`, the ``Deeplink/DeeplinksCenter`` will assign values to the properties on the newly created instance.
public protocol DefaultInitializable {
    init()
}
