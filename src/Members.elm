module Members exposing (Model(..), Msg(..), initialState, update, viewModel)

import Html exposing (..)
import Html.Events exposing (..)
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid

import Html.Attributes as HtmlAttr
import Html.Attributes exposing (..)
import Browser
import Dict
import Markdown
import View exposing (View)

import Bootstrap.Table as Table
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Button as Button
import Bootstrap.Dropdown as Dropdown
import Json.Decode as D

import Http

type alias SequenceResult =
    {seqid: String}

    {-{ aa: String
    , habitat: String
    , nuc: String
    , seqid: String
    , tax: String  }-}

type Model =
    Loading
    | LoadError String
    | Results APIResult

decodeSequenceResult : D.Decoder SequenceResult
decodeSequenceResult = 
    D.map SequenceResult
        -- (D.field "aminoacid" D.string)
        -- (D.field "habitat" D.string)
        -- (D.field "nucleotide" D.string)
        (D.field "seq_id" D.string)
        -- (D.field "taxonomy" D.string)

type APIResult =
        APIResultOK { cluster : List SequenceResult
                    , status : String
                    }
        | APIError String

type Msg
    = ResultsData (Result Http.Error APIResult)


decodeAPIResult : D.Decoder APIResult
decodeAPIResult =
    let
        bAPIResultOK r s = APIResultOK { cluster = r, status = s }
    in D.map2 bAPIResultOK
        (D.field "cluster" (D.list decodeSequenceResult))
        (D.field "status" D.string)

initialState : String -> (Model, Cmd Msg)
initialState seq_id = 
    ( Loading
    , Http.get
    { url = ("http://127.0.0.1:5001/v1/cluster-info/" ++ seq_id)
    , expect = Http.expectJson ResultsData decodeAPIResult
    }
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResultsData r -> case r of
            Ok v -> ( Results v, Cmd.none )
            Err err -> case err of
                Http.BadUrl s -> (LoadError ("Bad URL: "++ s) , Cmd.none)
                Http.Timeout  -> (LoadError ("Timeout") , Cmd.none)
                Http.NetworkError -> (LoadError ("Network error!") , Cmd.none)
                Http.BadStatus s -> (LoadError (("Bad status: " ++ String.fromInt s)) , Cmd.none)
                Http.BadBody s -> (LoadError (("Bad body: " ++ s)) , Cmd.none)

viewModel : Model-> Html Msg
viewModel model =
    case model of
        Loading ->
                div []
                    [ text "Loading..."
                    ]
        LoadError e ->
                div []
                    [ text "Error "
                    , text e
                    ]
        Results r -> viewResults r


viewResults r  = case r of
    APIResultOK ok ->
        div []
        [Table.table
                    { options = [ Table.striped, Table.hover ]
                    , thead =  Table.simpleThead
                        [ Table.th [] [ Html.text "100AA accession" ]
                        ]
                    , tbody = Table.tbody []
                            (List.map (\e ->
                                Table.tr []
                                    [ Table.td [] [ Html.text e.seqid ]
                                    ]) <|ok.cluster)
                    }
        ]
    APIError err ->
        div []
            [ Html.p [] [ Html.text "Call to the GMSC server failed" ]
            , Html.blockquote []
                [ Html.p [] [ Html.text err ] ]
            ]