port module GalleryInteraction exposing (elmToJS)

import Platform
import VegaLite exposing (..)



-- NOTE: All data sources in these examples originally provided at
-- https://github.com/vega/vega-datasets
-- The examples themselves reproduce those at https://vega.github.io/vega-lite/examples/


interaction1 : Spec
interaction1 =
    let
        des =
            description "A bar chart with highlighting on hover and selecting on click. Inspired by Tableau's interaction style."

        config =
            configure
                << configuration (coScale [ sacoBandPaddingInner 0.2 ])

        data =
            dataFromColumns []
                << dataColumn "a" (strs [ "A", "B", "C", "D", "E", "F", "G", "H", "I" ])
                << dataColumn "b" (nums [ 28, 55, 43, 91, 81, 53, 19, 87, 52 ])

        sel =
            selection
                << select "highlight" seSingle [ seOn "mouseover", seEmpty ]
                << select "select" seMulti []

        enc =
            encoding
                << position X [ pName "a", pMType Ordinal ]
                << position Y [ pName "b", pMType Quantitative ]
                << fillOpacity [ mSelectionCondition (selectionName "select") [ mNum 1 ] [ mNum 0.3 ] ]
                << strokeWidth
                    [ mDataCondition
                        [ ( and (selected "select") (expr "length(data(\"select_store\"))"), [ mNum 2 ] )
                        , ( selected "highlight", [ mNum 1 ] )
                        ]
                        [ mNum 0 ]
                    ]
    in
    toVegaLite
        [ des
        , config []
        , data []
        , sel []
        , bar [ maFill "#4C78A8", maStroke "black", maCursor cuPointer ]
        , enc []
        ]


interaction2 : Spec
interaction2 =
    let
        des =
            description "Scatterplot with external links and tooltips"

        trans =
            transform
                << calculateAs "'https://www.google.com/search?q=' + datum.Name" "url"

        enc =
            encoding
                << position X [ pName "Horsepower", pMType Quantitative ]
                << position Y [ pName "Miles_per_Gallon", pMType Quantitative ]
                << color [ mName "Origin", mMType Nominal ]
                << tooltip [ tName "Name", tMType Nominal ]
                << hyperlink [ hName "url", hMType Nominal ]
    in
    toVegaLite
        [ des
        , dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []
        , trans []
        , point []
        , enc []
        ]


interaction3 : Spec
interaction3 =
    let
        des =
            description "Drag out a rectangular brush to highlight points"

        sel =
            selection << select "myBrush" seInterval []

        enc =
            encoding
                << position X [ pName "Horsepower", pMType Quantitative ]
                << position Y [ pName "Miles_per_Gallon", pMType Quantitative ]
                << color
                    [ mSelectionCondition (selectionName "myBrush")
                        [ mName "Cylinders", mMType Ordinal ]
                        [ mStr "grey" ]
                    ]
    in
    toVegaLite
        [ des
        , dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []
        , point []
        , sel []
        , enc []
        ]


interaction4 : Spec
interaction4 =
    let
        des =
            description "Area chart with rectangular brush"

        trans =
            transform
                << filter (fiSelection "myBrush")

        sel =
            selection << select "myBrush" seInterval [ seEncodings [ chX ] ]

        enc =
            encoding
                << position X [ pName "date", pMType Temporal, pTimeUnit yearMonth ]
                << position Y [ pName "count", pMType Quantitative, pAggregate opSum ]

        specBackground =
            asSpec [ area [], sel [] ]

        specHighlight =
            asSpec [ area [ maColor "goldenrod" ], trans [] ]
    in
    toVegaLite
        [ des
        , dataFromUrl "https://vega.github.io/vega-lite/data/unemployment-across-industries.json" []
        , enc []
        , layer [ specBackground, specHighlight ]
        ]


interaction5 : Spec
interaction5 =
    let
        des =
            description "Mouse over individual points or select multiple points with the shift key"

        sel =
            selection << select "myPaintbrush" seMulti [ seOn "mouseover", seNearest True ]

        enc =
            encoding
                << position X [ pName "Horsepower", pMType Quantitative ]
                << position Y [ pName "Miles_per_Gallon", pMType Quantitative ]
                << size
                    [ mSelectionCondition (selectionName "myPaintbrush")
                        [ mNum 300 ]
                        [ mNum 50 ]
                    ]
    in
    toVegaLite
        [ des
        , dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []
        , point []
        , sel []
        , enc []
        ]


interaction6 : Spec
interaction6 =
    let
        des =
            description "Drag to pan. Zoom in or out with mousewheel/zoom gesture."

        sel =
            selection << select "myGrid" seInterval [ seBindScales ]

        enc =
            encoding
                << position X [ pName "Horsepower", pMType Quantitative, pScale [ scDomain (doNums [ 75, 150 ]) ] ]
                << position Y [ pName "Miles_per_Gallon", pMType Quantitative, pScale [ scDomain (doNums [ 20, 40 ]) ] ]
                << size [ mName "Cylinders", mMType Quantitative ]
    in
    toVegaLite
        [ des
        , dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []
        , circle []
        , sel []
        , enc []
        ]


interaction7 : Spec
interaction7 =
    let
        des =
            description "Drag the sliders to highlight points"

        trans =
            transform
                << calculateAs "year(datum.Year)" "Year"

        sel1 =
            selection
                << select "CylYr"
                    seSingle
                    [ seFields [ "Cylinders", "Year" ]
                    , seInit [ ( "Cylinders", num 4 ), ( "Year", num 1977 ) ]
                    , seBind
                        [ iRange "Cylinders" [ inName "Cylinders ", inMin 3, inMax 8, inStep 1 ]
                        , iRange "Year" [ inName "Year ", inMin 1969, inMax 1981, inStep 1 ]
                        ]
                    ]

        encPosition =
            encoding
                << position X [ pName "Horsepower", pMType Quantitative ]
                << position Y [ pName "Miles_per_Gallon", pMType Quantitative ]

        enc1 =
            encoding
                << color
                    [ mSelectionCondition (selectionName "CylYr")
                        [ mName "Origin", mMType Nominal ]
                        [ mStr "grey" ]
                    ]

        spec1 =
            asSpec [ sel1 [], circle [], enc1 [] ]

        trans2 =
            transform
                << filter (fiSelection "CylYr")

        enc2 =
            encoding
                << color [ mName "Origin", mMType Nominal ]
                << size [ mNum 100 ]

        spec2 =
            asSpec [ trans2 [], circle [], enc2 [] ]
    in
    toVegaLite
        [ des
        , dataFromUrl "https://vega.github.io/vega-lite/data/cars.json" []
        , trans []
        , encPosition []
        , layer [ spec1, spec2 ]
        ]


interaction8 : Spec
interaction8 =
    let
        des =
            description "Drag over bars to update selection average"

        sel =
            selection << select "myBrush" seInterval [ seEncodings [ chX ] ]

        encPosition =
            encoding << position Y [ pName "precipitation", pMType Quantitative, pAggregate opMean ]

        enc1 =
            encoding
                << position X [ pName "date", pMType Ordinal, pTimeUnit month ]
                << opacity
                    [ mSelectionCondition (selectionName "myBrush")
                        [ mNum 1 ]
                        [ mNum 0.7 ]
                    ]

        spec1 =
            asSpec [ sel [], bar [], enc1 [] ]

        trans =
            transform
                << filter (fiSelection "myBrush")

        enc2 =
            encoding
                << color [ mStr "firebrick" ]
                << size [ mNum 3 ]

        spec2 =
            asSpec [ des, trans [], rule [], enc2 [] ]
    in
    toVegaLite
        [ dataFromUrl "https://vega.github.io/vega-lite/data/seattle-weather.csv" []
        , encPosition []
        , layer [ spec1, spec2 ]
        ]


interaction9 : Spec
interaction9 =
    let
        desc =
            description "Displays tooltips for all stock prices of the hovered time"

        enc1 =
            encoding
                << position X [ pName "date", pMType Temporal ]
                << position Y [ pName "price", pMType Quantitative ]
                << color [ mName "symbol", mMType Nominal ]

        spec1 =
            asSpec
                [ enc1 []
                , layer
                    [ asSpec [ line [] ]
                    , asSpec [ point [], sel1_2 [], enc1_2 [] ]
                    ]
                ]

        enc1_2 =
            encoding
                << opacity [ mSelectionCondition (expr "myTooltip") [ mNum 1 ] [ mNum 0 ] ]

        sel1_2 =
            selection
                << select "myTooltip"
                    seSingle
                    [ seNearest True
                    , seOn "mouseover"
                    , seEncodings [ chX ]
                    , seEmpty
                    ]

        spec2 =
            asSpec [ trans2 [], layer [ spec2_1, spec2_2 ] ]

        trans2 =
            transform << filter (fiSelection "myTooltip")

        spec2_1 =
            asSpec [ rule [ maColor "gray" ], enc2_1 [] ]

        enc2_1 =
            encoding << position X [ pName "date", pMType Temporal ]

        spec2_2 =
            asSpec [ textMark [ maAlign haLeft, maDx 5, maDy -5 ], enc2_2 [] ]

        enc2_2 =
            encoding
                << position X [ pName "date", pMType Temporal ]
                << position Y [ pName "price", pMType Quantitative ]
                << text [ tName "price", tMType Quantitative ]
                << color [ mName "symbol", mMType Nominal ]
    in
    toVegaLite
        [ width 800
        , height 400
        , dataFromUrl "https://vega.github.io/vega-lite/data/stocks.csv" [ parse [ ( "date", foDate "" ) ] ]
        , layer [ spec1, spec2 ]
        ]


interaction10 : Spec
interaction10 =
    let
        desc =
            description "Multi Series Line Chart with Tooltip"

        config =
            configure
                << configuration (coAxisY [ axcoMinExtent 30 ])

        enc =
            encoding
                << position X [ pName "date", pMType Temporal, pTimeUnit yearMonthDate ]
                << tooltips
                    [ [ tName "date", tMType Temporal, tTimeUnit yearMonthDate ]
                    , [ tName "temp_max", tMType Quantitative ]
                    , [ tName "temp_min", tMType Quantitative ]
                    ]

        enc1 =
            encoding
                << position Y [ pName "temp_max", pMType Quantitative ]

        spec1 =
            asSpec [ line [ maColor "orange" ], enc1 [] ]

        enc2 =
            encoding
                << position Y [ pName "temp_min", pMType Quantitative ]

        spec2 =
            asSpec [ line [ maColor "red" ], enc2 [] ]

        sel =
            selection
                << select "hover" seSingle [ seOn "mouseover", seEmpty ]

        enc3 =
            encoding
                << color
                    [ mSelectionCondition (VegaLite.not (selectionName "hover"))
                        [ mStr "transparent" ]
                        []
                    ]

        spec3 =
            asSpec [ sel [], rule [], enc3 [] ]
    in
    toVegaLite
        [ config []
        , dataFromUrl "https://vega.github.io/vega-lite/data/seattle-weather.csv" []
        , enc []
        , layer [ spec1, spec2, spec3 ]
        ]



{- This list comprises the specifications to be provided to the Vega-Lite runtime. -}


mySpecs : Spec
mySpecs =
    combineSpecs
        [ ( "interaction1", interaction1 )
        , ( "interaction2", interaction2 )
        , ( "interaction3", interaction3 )
        , ( "interaction4", interaction4 )
        , ( "interaction5", interaction5 )
        , ( "interaction6", interaction6 )
        , ( "interaction7", interaction7 )
        , ( "interaction8", interaction8 )
        , ( "interaction9", interaction9 )
        , ( "interaction10", interaction10 )
        ]



{- The code below is boilerplate for creating a headless Elm module that opens
   an outgoing port to Javascript and sends the specs to it.
-}


main : Program () Spec msg
main =
    Platform.worker
        { init = always ( mySpecs, elmToJS mySpecs )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        }


port elmToJS : Spec -> Cmd msg
