import 'package:hasura_connect/hasura_connect.dart';

class CustomHasuraConnect {
  static HasuraConnect getConnect() {
    return HasuraConnect("http://172.233.121.149:8080/v1/graphql",
        headers: {'x-hasura-admin-secret': 'KFqq8LLMFJY7jE7bGkYmqafbPF2wpqCA'});
  }
}
