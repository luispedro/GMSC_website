module Example exposing
    ( Model
    , Msg(..)
    , update
    , view
    , initialModel
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Selects
import Shared

type alias Model item =
    { id : String
    , available : List item
    , itemToLabel : item -> String
    , selected : List item
    , selectState : Selects.State
    , selectConfig : Selects.Config (Msg item) item
    }

type alias InitArgs item =
    { id: String
    , available : List item
    , selected : List item
    , selectConfig : Selects.Config (Msg item) item
    , itemToLabel : item -> String
    }

initialModel : InitArgs item -> Model item
initialModel args =
    { id = args.id
    , available = args.available
    , itemToLabel = args.itemToLabel
    , selected = args.selected
    , selectState = Selects.init args.id
    , selectConfig = args.selectConfig
    }

type Msg item
    = NoOp
    | OnSelect (Maybe item)
    | OnSingleSelect (Maybe item)
    | SelectMsg (Selects.Msg item)

update : Msg item -> Model item -> ( Model item, Cmd (Msg item) )
update msg model =
    case msg of
        OnSelect maybeColor ->
            let
                selected =
                    maybeColor
                        |> Maybe.map (List.singleton >> List.append model.selected)
                        |> Maybe.withDefault []
            in
            ( { model | selected = selected }, Cmd.none )

        OnSingleSelect maybeColor ->
            case maybeColor of
              Just a ->
                ( { model | selected = [a] }, Cmd.none )
              Nothing -> 
                ( { model | selected = [] }, Cmd.none )

        SelectMsg subMsg ->
            let
                ( updated, cmd ) =
                    Selects.update
                        model.selectConfig
                        subMsg
                        model.selectState
            in
            ( { model | selectState = updated }, cmd )

        NoOp ->
            ( model, Cmd.none )

view : Model item -> String -> Html (Msg item)
view model prompt =
    let
        currentSelection =
            p
                []
                [ text (String.join ", " <| List.map model.itemToLabel model.selected) ]

        select =
            Selects.view
                model.selectConfig
                model.selectState
                model.available
                model.selected
    in
    div [ ]
        [ p
            []
            [ label [] [ text prompt ]
            ]
        , p
            []
            [ select
            ]
        , currentSelection
        ]