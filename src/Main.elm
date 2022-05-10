module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Html
    exposing
        ( Html
        , button
        , div
        , form
        , h1
        , header
        , input
        , label
        , li
        , main_
        , p
        , text
        )
import Html.Attributes
    exposing
        ( checked
        , class
        , disabled
        , for
        , id
        , placeholder
        , type_
        , value
        )
import Html.Events exposing (onCheck, onClick, onInput, onSubmit)
import Html.Keyed exposing (ul)
import Html.Lazy exposing (lazy, lazy2, lazy3)



-- MAIN


main : Program () Model Msg
main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { content : String
    , showCompleted : Bool
    , search : String
    , todos : Dict String Bool
    }


init : Model
init =
    Model "" False "" Dict.empty



-- UPDATE


type Msg
    = Add
    | ChangeContent String
    | ChangeSearch String
    | CheckShowCompleted Bool
    | CheckTodo String Bool
    | Delete String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Add ->
            let
                content =
                    String.trim model.content
            in
            if String.isEmpty content then
                model

            else
                { model
                    | content = ""
                    , todos = Dict.insert content False model.todos
                }

        ChangeContent content ->
            { model | content = content }

        ChangeSearch search ->
            { model | search = search }

        CheckShowCompleted showCompleted ->
            { model | showCompleted = showCompleted }

        CheckTodo todo completed ->
            { model
                | todos =
                    Dict.update
                        todo
                        (Maybe.map <| always completed)
                        model.todos
            }

        Delete todo ->
            { model | todos = Dict.remove todo model.todos }



-- VIEW


filterTodos : Bool -> String -> String -> Bool -> Bool
filterTodos showCompleted search todo completed =
    let
        needle =
            search |> String.trim |> String.toLower
    in
    (showCompleted || not completed)
        && (String.isEmpty needle
                || (todo |> String.toLower |> String.contains needle)
           )


viewControls : Bool -> String -> Html Msg
viewControls showCompleted search =
    div [ class "flex flex-wrap gap-2 items-center mb-4" ]
        [ input
            [ checked showCompleted
            , id "showCompleted"
            , onCheck CheckShowCompleted
            , type_ "checkbox"
            ]
            []
        , label [ class "grow", for "showCompleted" ] [ text "Show Completed" ]
        , input
            [ onInput ChangeSearch
            , placeholder "Search"
            , type_ "text"
            , value search
            ]
            []
        ]


viewTodo : String -> Bool -> Html Msg
viewTodo todo completed =
    li [ class "flex gap-2 items-center" ]
        [ input
            [ checked completed
            , onCheck <| CheckTodo todo
            , type_ "checkbox"
            ]
            []
        , p [ class "grow" ] [ text todo ]
        , button
            [ class "bg-red-500 px-2 py-1 rounded text-white"
            , onClick <| Delete todo
            ]
            [ text "X" ]
        ]


viewTodos : Bool -> String -> Dict String Bool -> Html Msg
viewTodos showCompleted search todos =
    todos
        |> Dict.filter (filterTodos showCompleted search)
        |> Dict.map (lazy2 viewTodo)
        |> Dict.toList
        |> ul [ class "mb-4 space-y-2" ]


viewAddTodo : String -> Html Msg
viewAddTodo content =
    form [ class "flex gap-2 items-center mb-4", onSubmit Add ]
        [ input
            [ class "grow"
            , onInput ChangeContent
            , placeholder "Add Todo"
            , type_ "text"
            , value content
            ]
            []
        , button
            [ class "bg-blue-500 disabled:contrast-50 px-4 py-2 rounded text-white transition-all"
            , disabled <| String.isEmpty <| String.trim content
            , type_ "submit"
            ]
            [ text "Add" ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ header [ class "bg-blue-500 mb-4 p-4" ]
            [ h1 [ class "container font-semibold mx-auto text-white text-xl" ]
                [ text "ToDos" ]
            ]
        , main_ [ class "max-w-prose mx-auto px-4" ]
            [ lazy2 viewControls model.showCompleted model.search
            , lazy3 viewTodos model.showCompleted model.search model.todos
            , lazy viewAddTodo model.content
            ]
        ]
