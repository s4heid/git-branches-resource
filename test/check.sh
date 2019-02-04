#!/bin/sh

set -e

source $(dirname $0)/helpers.sh

it_can_check_from_no_version() {
  local repo=$(init_repo)

  make_commit_to_branch $repo branch-a
  make_commit_to_branch $repo branch-b

  check_uri $repo | jq -e '
    . == [{
      branches: "branch-a\nbranch-b\nmaster",
      added: "branch-a\nbranch-b\nmaster",
      removed: ""
    }]
  '
}

it_can_check_with_added_branch() {
  local repo=$(init_repo)

  make_commit_to_branch $repo branch-a
  make_commit_to_branch $repo branch-b

  check_uri_from $repo $'branch-a\nmaster' | jq -e '
    . == [{
    branches: "branch-a\nbranch-b\nmaster",
    added: "branch-b",
    removed: ""
  }]
  '
}

it_can_check_with_removed_branch() {
  local repo=$(init_repo)

  make_commit_to_branch $repo branch-a
  make_commit_to_branch $repo branch-b

  check_uri_from $repo $'branch-a\nbranch-b\nbranch-c\nmaster' | jq -e '
    . == [{
      branches: "branch-a\nbranch-b\nmaster",
      added: "",
      removed: "branch-c"
    }]
  '
}

it_can_check_with_added_and_removed_branches() {
  local repo=$(init_repo)

  make_commit_to_branch $repo branch-a
  make_commit_to_branch $repo branch-d
  make_commit_to_branch $repo branch-e

  check_uri_from $repo $'branch-a\nbranch-b\nbranch-c\nmaster' | jq -e '
    . == [{
      branches: "branch-a\nbranch-d\nbranch-e\nmaster",
      added: "branch-d\nbranch-e",
      removed: "branch-b\nbranch-c"
    }]
  '
}

it_can_check_with_filter() {
  local repo=$(init_repo)
  local filter="^matching-branch-[ab]$"

  make_commit_to_branch $repo matching-branch-a
  make_commit_to_branch $repo matching-branch-b
  make_commit_to_branch $repo not-matching-branch-a

  check_uri_with_filter_from $repo $filter $'matching-branch-a' | jq -e '
    . == [{
      branches: "matching-branch-a\nmatching-branch-b",
      added: "matching-branch-b",
      removed: ""
    }]
  '
}

run it_can_check_from_no_version
run it_can_check_with_added_branch
run it_can_check_with_removed_branch
run it_can_check_with_added_and_removed_branches
run it_can_check_with_filter
