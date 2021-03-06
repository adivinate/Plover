defmodule Github.State do
    @moduledoc """
        Structure for what each worker will use to control their given pull request's
    """

    @type t :: %__MODULE__{
        owners: list(tuple()),
        reviewers: list(tuple()),
        action_history: list(String.t),
        targeted_users: list(tuple()),
        message_type: String.t,
        pull_request_url: String.t
    }

    @derive [Poison.Encoder]
    defstruct [
        owners: [],
        reviewers: [],
        action_history: [],
        targeted_users: [],
        message_type: nil,
        pull_request_url: nil
    ]

    defimpl Poison.Encoder, for: Tuple do
        def encode(tuple, _options) do
          tuple |> Tuple.to_list |> Poison.encode!
        end
    end

    defimpl Poison.Decoder, for: Github.State do
        def decode(state, _options) do
            %{state |
                reviewers: decode_tuple_list(state.reviewers),
                owners: decode_tuple_list(state.owners),
                targeted_users: decode_tuple_list(state.targeted_users)
            }
        end

        def decode_tuple_list([raw_tuple | tail]), do: [List.to_tuple(raw_tuple) | decode_tuple_list(tail)]
        def decode_tuple_list([]), do: []
    end
end
