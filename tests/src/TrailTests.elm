port module TrailTests exposing (elmToJS)

import Browser
import Html exposing (Html, div, pre)
import Html.Attributes exposing (id)
import Json.Encode
import VegaLite exposing (..)


trail1 : Spec
trail1 =
    let
        enc =
            encoding
                << position X [ pName "date", pTemporal, pAxis [ axFormat "%Y" ] ]
                << position Y [ pName "price", pQuant ]
                << size [ mName "price", mQuant ]
                << color [ mName "symbol", mNominal ]
    in
    toVegaLite
        [ width 400
        , height 400
        , dataFromUrl "https://vega.github.io/vega-lite/data/stocks.csv" []
        , trail []
        , enc []
        ]


trail2 : Spec
trail2 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/driving.json"

        enc =
            encoding
                << position X [ pName "miles", pQuant, pScale [ scZero False ] ]
                << position Y [ pName "gas", pQuant, pScale [ scZero False ] ]
                << size [ mName "year", mTemporal, mLegend [] ]
    in
    toVegaLite [ data [], trail [ maOrder False ], enc [] ]


sourceExample : Spec
sourceExample =
    trail2



{- This list comprises the specifications to be provided to the Vega-Lite runtime. -}


mySpecs : Spec
mySpecs =
    combineSpecs
        [ ( "trail1", trail1 )
        , ( "trail2", trail2 )
        ]



{- ---------------------------------------------------------------------------
   The code below creates an Elm module that opens an outgoing port to Javascript
   and sends both the specs and DOM node to it.
   This is used to display the generated Vega specs for testing purposes.
-}


main : Program () Spec msg
main =
    Browser.element
        { init = always ( mySpecs, elmToJS mySpecs )
        , view = view
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        }



-- View


view : Spec -> Html msg
view spec =
    div []
        [ div [ id "specSource" ] []
        , pre []
            [ Html.text (Json.Encode.encode 2 sourceExample) ]
        ]


port elmToJS : Spec -> Cmd msg
