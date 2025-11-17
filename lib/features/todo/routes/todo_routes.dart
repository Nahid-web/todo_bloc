import 'package:go_router/go_router.dart';

import '../presentation/pages/add_edit_todo_page.dart';
import '../presentation/pages/todo_detail_page.dart';
import '../presentation/pages/todo_list_page.dart';

final todoRoutes = [
  GoRoute(
    path: '/todos',
    builder: (context, state) => const TodoListPage(),
    routes: [
      GoRoute(
        path: 'add',
        builder: (context, state) => const AddEditTodoPage(),
      ),
      GoRoute(
        path: 'edit/:todoId',
        builder: (context, state) => AddEditTodoPage(
          todoId: state.pathParameters['todoId']!,
        ),
      ),
      GoRoute(
        path: 'detail/:todoId',
        builder: (context, state) => TodoDetailPage(
          todoId: state.pathParameters['todoId']!,
        ),
      ),
    ],
  ),
];
