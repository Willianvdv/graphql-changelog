require 'pry'
require 'httparty'
require 'graphql'

INTROSPECTION_QUERY = '''
  query IntrospectionQuery {
    __schema {
      queryType { name }
      mutationType { name }
      subscriptionType { name }
      types {
        ...FullType
      }
      directives {
        name
        description
        args {
          ...InputValue
        }
        onOperation
        onFragment
        onField
      }
    }
  }

  fragment FullType on __Type {
    kind
    name
    description
    fields(includeDeprecated: true) {
      name
      description
      args {
        ...InputValue
      }
      type {
        ...TypeRef
      }
      isDeprecated
      deprecationReason
    }
    inputFields {
      ...InputValue
    }
    interfaces {
      ...TypeRef
    }
    enumValues(includeDeprecated: true) {
      name
      description
      isDeprecated
      deprecationReason
    }
    possibleTypes {
      ...TypeRef
    }
  }

  fragment InputValue on __InputValue {
    name
    description
    type { ...TypeRef }
    defaultValue
  }

  fragment TypeRef on __Type {
    kind
    name
    ofType {
      kind
      name
      ofType {
        kind
        name
        ofType {
          kind
          name
        }
      }
    }
  }
'''

class IntrospectHackerOne
  def introspect
    response = HTTParty.post(
      'https://hackerone.com/graphql',
      body: {
        query: INTROSPECTION_QUERY,
        variables: ''
      },
      # :debug_output => $stdout
    )

    introspection_result = response.parsed_response
    schema = GraphQL::Schema.from_introspection introspection_result
    p schema.to_definition
    IO.write('results/hackerone.graphql', schema.to_definition)
  end
end

IntrospectHackerOne.new.introspect

