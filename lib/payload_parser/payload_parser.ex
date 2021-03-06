defmodule PayloadParser do
    @moduledoc """
        Extracts information from a github pull request
    """
    alias PayloadParser.Payload

    @doc """
        Returns the action of the supplied payload

        Returns
            - Action that was found

        ## Examples
        iex> %{"action" => "submitted"}
        iex> |> PayloadParser.action()
        "submitted"
    """
    def action(%{"action" => pr_action}), do: pr_action
    def action(_), do: nil

    def action_state(payload, state), do: state == action(payload)

    @doc """
        Returns the Organization's full name

        Returns
            - name if success
            - nil if name is not found

        ## Examples
        iex> %{"organization" => %{"login" => "org-name"}}
        iex> |> PayloadParser.organization_name()
        "org-name"
    """
    def organization_name(%{"organization" => %{"login" => name}}), do: name
    def organization_name(_), do: nil

    @doc """
        Returns the Organization urls

        Returns
            - url if success
            - nil if url is not found

        ## Examples
        iex> %{"organization" => %{"url" => "http://google.com"}}
        iex> |> PayloadParser.organization_url()
        "http://google.com"
    """
    def organization_url(%{"organization" => %{"url" => url}}), do: url
    def organization_url(_), do: nil

    @doc """
        Returns the Projects name

        Returns
            - name if success
            - nil if name is not found

        ## Examples
        iex> %{"repository" => %{"full_name" => "Test Project"}}
        iex> |> PayloadParser.project_name()
        "Test Project"
    """
    def project_name(%{"repository" => %{"full_name" => name}}), do: name
    def project_name(_), do: nil

    @doc """
        Returns the Projects url

        Returns
            - url if success
            - nil if url is not found

        ## Examples
        iex> %{"repository" => %{"html_url" => "Test Project"}}
        iex> |> PayloadParser.project_url()
        "Test Project"
    """
    def project_url(%{"repository" => %{"html_url" => url}}), do: url
    def project_url(_), do: nil

    @doc """
        Returns the pull request url

        Returns
            - url if success
            - nil if url is not found

        ## Examples
        iex> %{"pull_request" => %{"html_url" => "http://my-url.com"}}
        iex> |> PayloadParser.pull_url()
        "http://my-url.com"
    """
    def pull_url(%{"pull_request" => %{"html_url" => url}}), do: url
    def pull_url(_), do: nil

    @doc """
        Returns the pull request name

        Returns
            - name if success
            - nil if name is not found

        ## Examples
        iex> %{"pull_request" => %{"title" => "My Pull Request"}}
        iex> |> PayloadParser.pull_name()
        "My Pull Request"
    """
    def pull_name(%{"pull_request" => %{"title" => name}}), do: name
    def pull_name(_), do: nil

    @doc """
        Returns the pull request status

        Returns
            - status if success
            - nil if name is not found

        ## Examples
        iex> %{"pull_request" => %{"state" => "open"}}
        iex> |> PayloadParser.pull_status()
        "open"
    """
    def pull_status(%{"pull_request" => %{"state" => status}}), do: status
    def pull_status(_), do: nil

    @doc """
        returns the pull request owner

        Returns
            - Github login of the person who initaliszed the pull request

        ## Examples
        iex> %{"pull_request" => %{"user" => %{"login" => "User1"}}}
        iex> |> PayloadParser.pull_owner()
        "User1"
    """
    def pull_owner(%{"pull_request" => pull_request}), do: pull_owner(pull_request)
    def pull_owner(%{"user" => %{"login" => login}}), do: login
    def pull_owner(_), do: nil

    @doc """
        Returns a list of reviewer login names

        Returns
            - List of login names

        ## Examples
        iex> %{"requested_reviewers" => [%{"login"=> "User1"}, %{"login"=> "User2"}]}
        iex> |> PayloadParser.reviewers()
        ["User1", "User2"]
    """
    def reviewers(%{"pull_request" => pull_request}), do: reviewers(pull_request)
    def reviewers(%{"requested_reviewers" => reviewers}), do: reviewers(reviewers)
    def reviewers([%{"login" => login} | reviewers]), do: [login | reviewers(reviewers)]
    def reviewers(_), do: []

    @doc """
        Returns the state for which the review status has been submitted as

        Returns
            - Review state

        ## Examples
        iex> %{"review" => %{"state" => "approved"}}
        iex> |> PayloadParser.review_state()
        "approved"
    """
    def review_state(%{"review" => %{"state" => state}}), do: state
    def review_state(_), do: nil

    @doc """
        Returns the github login who submitted a review

        Returns
            - Github login of reviewer

        ## Examples
        iex> %{"review" => %{"user" => %{"login" => "TestUser"}}}
        iex> |> PayloadParser.reviewer()
        "TestUser"
    """
    def reviewer(%{"review" => review}), do: reviewer(review)
    def reviewer(%{"user" => %{"login" => login}}), do: login
    def reviewer(_), do: nil

    @doc """
        Returns a single user reviewed based on an isolated action instance

        Ex: Action return was "review_request_removed"
        The "requested_reviewer" is the response to whome was removed

        Returns
            - Github login of reviewer

        ## Examples
        iex> %{"requested_reviewer" => %{"login" => "TestUser"}}
        iex> |> PayloadParser.requested_reviewer()
        "TestUser"
    """
    def requested_reviewer(%{"requested_reviewer" => reviewer}), do: requested_reviewer(reviewer)
    def requested_reviewer(%{"login" => login}), do: login
    def requested_reviewer(_), do: nil

    @doc """
        Returns a boolean value determinding if the pull request has been merged or not.

        ## Examples
        iex> %{"pull_request" => %{"merged_at" => "http://my-url.com"}}
        iex> |> PayloadParser.merged_state()
        true

        iex> %{"pull_request" => %{"merged_at" => nil}}
        iex> |> PayloadParser.merged_state()
        false
    """
    def merged_state(%{"pull_request" => %{"merged_at" => merged_at}}) do
        merged_at != nil
    end

    def merged_state(_), do: false

    @doc """
        Returns list of all avaiaible data in a PR

        Returns
            - %{...} if success
            - nil if failure
    """
    def request_details(payload) do
        %Payload{
            action: action(payload),
            organization_name: organization_name(payload),
            organization_url: organization_url(payload),
            project_name: project_name(payload),
            project_url: project_url(payload),
            pull_name: pull_name(payload),
            pull_url: pull_url(payload),
            pull_status: pull_status(payload),
            pull_owner: pull_owner(payload),
            review_state: review_state(payload),
            reviewer: reviewer(payload),
            reviewers: reviewers(payload),
            requested_reviewer: requested_reviewer(payload),
            has_been_merged: merged_state(payload),
            has_been_closed: action_state(payload, "closed")
        }
    end
end
