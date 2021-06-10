import Deeplink

let link1 = "/test/1" as Deeplink<Void>

func magicABTestIsOn() -> Bool { Bool.random() }

let center = DeeplinksCenter {

    if magicABTestIsOn() {
        link1 { url in
            // Present Screen A
            return true
        }
    }

    link1 { url in

        // Present WebView
        return true
    }
}

try center.parse(url: URL(string: "https://apple.com/test/1")!)
