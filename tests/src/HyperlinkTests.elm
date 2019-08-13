port module HyperlinkTests exposing (elmToJS)

import Browser
import Html exposing (Html, div, pre)
import Html.Attributes exposing (id)
import Json.Encode
import VegaLite exposing (..)


hyperlink1 : Spec
hyperlink1 =
    let
        data =
            dataFromColumns []
                << dataColumn "label" (strs [ "Vega", "Vega-Lite" ])
                << dataColumn "url" (strs [ "https://vega.github.io/vega", "https://vega.github.io/vega-lite" ])

        encCircle =
            encoding
                << position X [ pName "label", pNominal, pAxis [] ]
                << size [ mNum 8000 ]
                << color [ mName "label", mNominal, mLegend [] ]
                << hyperlink [ hName "url", hNominal ]

        encLabel =
            encoding
                << position X [ pName "label", pNominal, pAxis [] ]
                << text [ tName "label", tNominal ]
                << color [ mStr "white" ]
                << size [ mNum 16 ]

        symbolSpec =
            asSpec [ circle [ maCursor cuPointer ], encCircle [] ]

        labelSpec =
            asSpec [ textMark [], encLabel [] ]
    in
    toVegaLite
        [ data [], layer [ symbolSpec, labelSpec ] ]


hyperlink2 : Spec
hyperlink2 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/movies.json" []

        enc =
            encoding
                << position X [ pName "IMDB_Rating", pQuant ]
                << position Y [ pName "Rotten_Tomatoes_Rating", pQuant ]
                << hyperlink [ hStr "http://www.imdb.com" ]
    in
    toVegaLite [ data, point [ maCursor cuPointer ], enc [] ]


hyperlink3 : Spec
hyperlink3 =
    let
        data =
            dataFromUrl "https://vega.github.io/vega-lite/data/movies.json" []

        enc =
            encoding
                << position X [ pName "IMDB_Rating", pQuant ]
                << position Y [ pName "Rotten_Tomatoes_Rating", pQuant ]
                << color
                    [ mDataCondition
                        [ ( expr "datum.IMDB_Rating*10 > datum.Rotten_Tomatoes_Rating"
                          , [ mStr "steelblue" ]
                          )
                        ]
                        [ mStr "red" ]
                    ]
                << hyperlink
                    [ hDataCondition (expr "datum.IMDB_Rating*10 > datum.Rotten_Tomatoes_Rating")
                        [ hStr "http://www.imdb.com" ]
                        [ hStr "https://www.rottentomatoes.com" ]
                    ]
    in
    toVegaLite [ data, point [ maCursor cuPointer ], enc [] ]



{- This list comprises the specifications to be provided to the Vega-Lite runtime. -}


mySpecs : Spec
mySpecs =
    combineSpecs
        [ ( "hyperlink1", hyperlink1 )
        , ( "hyperlink2", hyperlink2 )
        , ( "hyperlink3", hyperlink3 )
        ]


sourceExample : Spec
sourceExample =
    hyperlink3



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
