port module ConditionalTests exposing (elmToJS)

import Browser
import Html exposing (Html, div, pre)
import Html.Attributes exposing (id)
import Json.Encode
import VegaLite exposing (..)


markCondition1 : Spec
markCondition1 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/movies.json" []

        config =
            configure
                << configuration (coRemoveInvalid False)

        enc =
            encoding
                << position X [ pName "IMDB_Rating", pMType Quantitative ]
                << position Y [ pName "Rotten_Tomatoes_Rating", pMType Quantitative ]
                << color
                    [ mDataCondition
                        [ ( or (expr "datum.IMDB_Rating === null")
                                (expr "datum.Rotten_Tomatoes_Rating === null")
                          , [ mStr "#ddd" ]
                          )
                        ]
                        [ mStr "#0099ee" ]
                    ]
    in
    toVegaLite [ config [], data, point [], enc [] ]


markCondition2 : Spec
markCondition2 =
    let
        data =
            dataFromColumns []
                << dataColumn "value" (nums [ 10, 20, 30, 40, 50, 60 ])

        enc =
            encoding
                << position X [ pName "value", pMType Ordinal ]
                << color
                    [ mDataCondition
                        [ ( expr "datum.value < 40", [ mStr "blue" ] )
                        , ( expr "datum.value < 50", [ mStr "red" ] )
                        , ( expr "datum.value < 60", [ mStr "yellow" ] )
                        ]
                        [ mStr "black" ]
                    ]
    in
    toVegaLite [ width 400, data [], circle [ maSize 800 ], enc [] ]


selectionCondition1 : Spec
selectionCondition1 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        sel =
            selection
                << select "alex"
                    seInterval
                    [ seOn "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    , seTranslate "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    ]
                << select "morgan"
                    seInterval
                    [ seOn "[mousedown[event.shiftKey], mouseup] > mousemove"
                    , seTranslate "[mousedown[event.shiftKey], mouseup] > mousemove"
                    , seSelectionMark [ smFill "#fdbb84", smFillOpacity 0.5, smStroke "#e34a33" ]
                    ]

        enc =
            encoding
                << position Y [ pName "Origin", pMType Ordinal ]
                << position X [ pName "Cylinders", pMType Ordinal ]
                << color [ mAggregate opCount, mName "*", mMType Quantitative ]
    in
    toVegaLite
        [ data, sel [], rect [ maCursor cuGrab ], enc [] ]


selectionCondition2 : Spec
selectionCondition2 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        sel =
            selection
                << select "alex"
                    seInterval
                    [ seOn "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    , seTranslate "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    ]
                << select "morgan"
                    seInterval
                    [ seOn "[mousedown[event.shiftKey], mouseup] > mousemove"
                    , seTranslate "[mousedown[event.shiftKey], mouseup] > mousemove"
                    , seSelectionMark [ smFill "#fdbb84", smFillOpacity 0.5, smStroke "#e34a33" ]
                    ]

        enc =
            encoding
                << position Y [ pName "Origin", pMType Ordinal ]
                << position X [ pName "Cylinders", pMType Ordinal ]
                << color
                    [ mSelectionCondition
                        (and (selectionName "alex") (selectionName "morgan"))
                        [ mAggregate opCount, mName "*", mMType Quantitative ]
                        [ mStr "gray" ]
                    ]
    in
    toVegaLite
        [ data, sel [], rect [ maCursor cuGrab ], enc [] ]


selectionCondition3 : Spec
selectionCondition3 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        trans =
            transform
                << filter (fiCompose (and (selected "brush") (expr "datum.Weight_in_lbs > 3000")))

        sel =
            selection
                << select "brush" seInterval []

        enc1 =
            encoding
                << position X [ pName "Horsepower", pMType Quantitative ]
                << position Y [ pName "Miles_per_Gallon", pMType Quantitative ]

        spec1 =
            asSpec [ sel [], point [], enc1 [] ]

        enc2 =
            encoding
                << position X [ pName "Acceleration", pMType Quantitative, pScale [ scDomain (doNums [ 0, 25 ]) ] ]
                << position Y [ pName "Displacement", pMType Quantitative, pScale [ scDomain (doNums [ 0, 500 ]) ] ]

        spec2 =
            asSpec [ trans [], point [], enc2 [] ]
    in
    toVegaLite
        [ data, vConcat [ spec1, spec2 ] ]


selectionCondition4 : Spec
selectionCondition4 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        sel =
            selection
                << select "mySelection"
                    seInterval
                    [ seClear ""
                    , seOn "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    , seTranslate "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    ]

        enc =
            encoding
                << position Y [ pName "Origin", pMType Ordinal ]
                << position X [ pName "Cylinders", pMType Ordinal ]
                << color
                    [ mSelectionCondition
                        (selectionName "mySelection")
                        [ mAggregate opCount, mName "*", mMType Quantitative ]
                        [ mStr "gray" ]
                    ]
    in
    toVegaLite
        [ data, sel [], rect [ maCursor cuGrab ], enc [] ]


selectionCondition5 : Spec
selectionCondition5 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []

        sel =
            selection
                << select "mySelection"
                    seInterval
                    [ seClear "mouseup"
                    , seEmpty
                    , seOn "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    , seTranslate "[mousedown[!event.shiftKey], mouseup] > mousemove"
                    ]

        enc =
            encoding
                << position Y [ pName "Origin", pMType Ordinal ]
                << position X [ pName "Cylinders", pMType Ordinal ]
                << color
                    [ mSelectionCondition
                        (selectionName "mySelection")
                        [ mAggregate opCount, mName "*", mMType Quantitative ]
                        [ mStr "gray" ]
                    ]
    in
    toVegaLite
        [ data, sel [], rect [ maCursor cuGrab ], enc [] ]


bindScales1 : Spec
bindScales1 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json"

        sel =
            selection
                << select "myZoomPan" seInterval [ seBindScales ]

        enc =
            encoding
                << position X [ pName "Horsepower", pMType Quantitative ]
                << position Y [ pName "Miles_per_Gallon", pMType Quantitative ]
    in
    toVegaLite
        [ width 300, height 300, data [], sel [], circle [], enc [] ]


bindScales2 : Spec
bindScales2 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/cars.json"

        sel =
            selection
                << select "myZoomPan"
                    seInterval
                    [ seBindScales, seClear "click[event.shiftKey]" ]

        enc =
            encoding
                << position X [ pName "Horsepower", pMType Quantitative ]
                << position Y [ pName "Miles_per_Gallon", pMType Quantitative ]
    in
    toVegaLite
        [ width 300, height 300, data [], sel [], circle [], enc [] ]



{- This list comprises the specifications to be provided to the Vega-Lite runtime. -}


mySpecs : Spec
mySpecs =
    combineSpecs
        [ ( "markCondition1", markCondition1 )
        , ( "markCondition2", markCondition2 )
        , ( "selectionCondition1", selectionCondition1 )
        , ( "selectionCondition2", selectionCondition2 )
        , ( "selectionCondition3", selectionCondition3 )
        , ( "selectionCondition4", selectionCondition4 )
        , ( "selectionCondition5", selectionCondition5 )
        , ( "bindScales1", bindScales1 )
        , ( "bindScales2", bindScales2 )
        ]


sourceExample : Spec
sourceExample =
    bindScales2



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
