#!/usr/bin/env python3

"""
Get a json dump of all the repos belonging to a GitHub org or user.
"""

import json
import os
import sys
from functools import reduce

import requests

url = "https://api.github.com/graphql"
token = os.environ["GITHUB_TOKEN"]

headers = {"Authorization": "bearer {}".format(token)}

FIELDS = [
    "name",
    "description",
    "sshUrl",
    "isArchived",
    "isFork",
    "isPrivate",
    "pushedAt",
]


def query(who, after):
    args = f'first:100, after:"{after}"' if after else "first:100"
    fields = " ".join(FIELDS)
    return f'query {{ organization(login: "{who}") {{ repositories({args}) {{ edges {{ cursor node {{{fields} defaultBranchRef {{ name }} }} }} }} }} }}'


def maybe_get(top, *path):
    return reduce(lambda d, k: None if d is None else d.get(k), path, top)


def node(edge):
    n = edge["node"]
    return {
        **{f: n.get(f) for f in FIELDS},
        "defaultBranch": maybe_get(n, "defaultBranchRef", "name"),
    }


if __name__ == "__main__":

    who = sys.argv[1]

    edges = True
    after = None

    while edges:
        r = requests.post(url, json={"query": query(who, after)}, headers=headers)
        edges = json.loads(r.text)["data"]["organization"]["repositories"]["edges"]
        for e in edges:
            print(json.dumps(node(e)))
            after = edges[-1]["cursor"]
