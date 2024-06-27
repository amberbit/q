# Q

![Q](./assets/q.jpg)

Ad-hoc Ecto queries made simple as snapping your fingers. It's easy to use and saves you time, and the intended use case is to make ad-hoc changes to records from Elixir interactive console easier.

But you'll do whatever you want to do with it, you're the boss. Just remember: with great power comes great responsibility.

## Installation

```elixir
def deps do
  [
    {:q, "~> 2.0"}
  ]
end
```


## Configuration

```elixir
config :q, ecto_repo: MyApp.Repo
```

## Usage

NOTE: Everything below is the intended API, not everything may be implemented.

### Querying with `Q`
```elixir

# No conditions, fetches all records:
users = Q.all(User)

# Specify conditions any way you like:
users = Q.all(User, name: "John")
# or
users = Q.all(User, %{name: "John"}))
# or
users = Q.all(User, %{"name" => "John"})

# You can also pass options to Ecto.Repo:
users = Q.all(User, %{"name" => "John"}, timeout: :infinity)

# Converts nil to "IS NULL" and assumes you know what you're doing:
users = Q.all(User, deleted_at: nil)

# Allows to query for single records

user = Q.one(User, name: "John")
user = Q.one(User, %{id: 23})

# or use first to fetch first of many records
user = Q.first(User, name: "John")
```

`Q.one/2` and `Q.first/2` have also `!` versions `Q.one!` and `Q.find!` that will raise `Ecto.NoResultsError` if no record is found.

### Advanced querying and scopes

Q can use, return and chain Ecto queries with `Q.where`: 
```elixir
query = Q.where(User, name: "John", deleted_at: nil)

users = Q.all(query) # you can also use MyApp.Repo.all() with the query

# refining queries:
filtered_query = Q.where(query, age: 23)
filtered_users = Q.all(filtered_query)

# you can also use Ecto to refine query further and use features Q does not support (yet):
import Ecto.Query, only: [from: 2]

sorted_query = query |> from(u in filtered_query, order_by: [asc: u.age], limit: 5)

```

### Updating records
```elixir
user = Q.first(User, name: "John")

# this calls User.chaneset/2 implicitly
{:ok, updated_user} = Q.update(user, %{name: "Jane"})

# or you can specify a custom changeset function:

{:ok, updated_user} = Q.update(user, %{name: "Jane"}, &User.registration_changeset/2)

# or use the ! version if you want to raise on error / receive record not wrapped in tuple

updated_user = Q.update!(user, %{name: "Jane"}, &User.registration_changeset/2)


```

### Deleting records

You can delete single records, list of records, or records returned by query:
```elixir
:ok = Q.delete(user)
:ok = Q.delete([user1, user2])
:ok = Q.delete(Q.where(User, name: "John"))
```

### Transactions

Use `Q.begin()` and `Q.commit()` or `Q.rollback()` to use transactions.

```elixir
Q.begin()
Q.delete(user)
Q.rollback() # one user was saved today!


