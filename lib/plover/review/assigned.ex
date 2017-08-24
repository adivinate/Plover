defmodule Plover.Review.Assigned do
    @moduledoc """
        Parses the requrements for submitting a slack message based on a `review` request.

        All review requests go through a assignment process, which replaces or creates
        reviewers for a given pull request.
    """

    alias Plover.{Github, Github.PullRequest}
    alias Integration.Github.{PayloadParser, Payload}

    @doc """
        Esablishes links between Projects, Pull Requests and Reviewers

        Returns the pull request
    """
    def review(%Payload{} = payload, preload: preload) do
        {:ok, pull_request} =
             payload
             |> Github.find_or_create_project()
             |> Github.find_or_create_pull_request(payload)

        Github.assign_reviewers(pull_request, payload)

        if preload do
            PullRequest.find(pull_request.id, :preload)
        else
            pull_request
        end
     end

     def review(raw_payload, params) do
        raw_payload |> PayloadParser.request_details() |> review(params)
     end
end
