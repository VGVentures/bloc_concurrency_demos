import 'dart:async';

import 'package:bloc_concurrency_demos/files/bloc/file_cubit.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_events.dart';
import 'package:bloc_concurrency_demos/files/bloc/file_state.dart';
import 'package:bloc_concurrency_demos/files/file_repo.dart';
import 'package:bloc_concurrency_demos/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Files extends StatelessWidget {
  const Files({Key? key, required this.isOld}) : super(key: key);

  final bool isOld;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FileCubit(isOld: isOld, fileRepo: FileRepo())..add(const LoadFiles()),
      child: FilesView(isOld: isOld),
    );
  }
}

class FilesView extends StatefulWidget {
  const FilesView({Key? key, required this.isOld}) : super(key: key);

  final bool isOld;

  @override
  State<FilesView> createState() => _FilesViewState();
}

class _FilesViewState extends State<FilesView> {
  Completer<void> _reloadFiles = Completer();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isOld ? l10n.filesViewTitleOld : l10n.filesViewTitleNew,
        ),
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, 6),
          child: BlocBuilder<FileCubit, FileState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const LinearProgressIndicator();
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
      body: BlocConsumer<FileCubit, FileState>(
        // Only call bloc listener when the state has finished loading.
        listenWhen: (previous, current) =>
            previous.isLoading && !current.isLoading,
        listener: (context, state) {
          _reloadFiles.complete();
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () {
              _reloadFiles = Completer();
              BlocProvider.of<FileCubit>(context).add(const LoadFiles());
              return _reloadFiles.future;
            },
            child: ListView.builder(
              primary: true,
              itemCount: state.files.length,
              itemBuilder: (context, index) {
                final file = state.files[index];
                return ListTile(
                  key: ValueKey(file.id),
                  title: Text(file.name),
                  trailing: DeleteAction(
                    onTap: () async {
                      if (state.pendingDeletions.contains(file.id)) return;
                      BlocProvider.of<FileCubit>(context).add(
                        DeleteFile(fileId: file.id),
                      );
                    },
                    isLoading: state.pendingDeletions.contains(file.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DeleteAction extends StatelessWidget {
  const DeleteAction({
    Key? key,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onTap,
      icon: isLoading
          ? CircularProgressIndicator(color: theme.colorScheme.error)
          : const Icon(Icons.delete),
    );
  }
}
