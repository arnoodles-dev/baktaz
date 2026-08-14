// ignore_for_file: prefer-match-file-name

import 'package:baktaz_admin/features/localization/domain/entity/localization_key.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'localization_tree_builder.freezed.dart';

List<NamespaceNode> buildLocalizationTree(List<LocalizationKey> keys) {
  final Map<String, _MutableNamespace> namespaces = <String, _MutableNamespace>{};

  for (final LocalizationKey key in keys) {
    final _MutableNamespace nsNode = namespaces.putIfAbsent(key.namespace, () => _MutableNamespace(key.namespace));
    final List<String> segments = key.key.split('.');
    _insertKey(nsNode.children, segments, 0, key);
  }

  for (final _MutableNamespace nsNode in namespaces.values) {
    _sortChildren(nsNode.children);
  }

  return namespaces.values
      .map(
        (_MutableNamespace ns) => NamespaceNode(
          namespace: ns.namespace,
          children: ns.children.values.map((_MutableNode c) => c.toFreezed()).toList(),
        ),
      )
      .toList()
    ..sort((NamespaceNode a, NamespaceNode b) => a.namespace.compareTo(b.namespace));
}

void _sortChildren(Map<String, _MutableNode> nodes) {
  final List<_MutableNode> sorted = nodes.values.toList()
    ..sort((_MutableNode a, _MutableNode b) {
      if (a is _MutableGroup && b is _MutableLeaf) return -1;
      if (a is _MutableLeaf && b is _MutableGroup) return 1;

      if (a is _MutableGroup && b is _MutableGroup) {
        final int cmp = b.groupCount.compareTo(a.groupCount);
        if (cmp != 0) return cmp;
      }
      return a.name.compareTo(b.name);
    });

  nodes.clear();
  for (final _MutableNode node in sorted) {
    nodes[node.name] = node;
  }

  for (final _MutableNode node in sorted) {
    if (node is _MutableGroup) {
      _sortChildren(node.children);
    }
  }
}

void _insertKey(Map<String, _MutableNode> siblings, List<String> segments, int index, LocalizationKey key) {
  if (index >= segments.length) return;

  final String segment = segments[index];
  final String currentFullPath = '${key.namespace}.${segments.sublist(0, index + 1).join('.')}';

  if (index == segments.length - 1) {
    siblings[segment] = _MutableLeaf(segment, currentFullPath, key);
  } else {
    final _MutableNode existing = siblings.putIfAbsent(segment, () => _MutableGroup(segment, currentFullPath));
    _insertKey((existing as _MutableGroup).children, segments, index + 1, key);
  }
}

@freezed
abstract class NamespaceNode with _$NamespaceNode {
  const factory NamespaceNode({required String namespace, @Default(<TreeNode>[]) List<TreeNode> children}) =
      _NamespaceNode;
}

@freezed
abstract class TreeNode with _$TreeNode {
  const factory TreeNode.group({required String name, required String fullPath, required List<TreeNode> children}) =
      GroupNode;

  const factory TreeNode.leaf({
    required String name,
    required String fullPath,
    required LocalizationKey localizationKey,
  }) = LeafNode;
}

// --- Private mutable classes for building tree before freezing ---

abstract class _MutableNode {
  _MutableNode(this.name, this.fullPath);
  final String name;
  final String fullPath;

  TreeNode toFreezed();
}

class _MutableNamespace {
  _MutableNamespace(this.namespace);
  final String namespace;
  final Map<String, _MutableNode> children = <String, _MutableNode>{};
}

class _MutableGroup extends _MutableNode {
  _MutableGroup(super.name, super.fullPath);
  final Map<String, _MutableNode> children = <String, _MutableNode>{};
  int? _cachedGroupCount;

  int get groupCount => _cachedGroupCount ??= _computeCount();

  int _computeCount() {
    int count = 1;
    for (final _MutableNode child in children.values) {
      if (child is _MutableGroup) {
        count += child.groupCount;
      }
    }
    return count;
  }

  @override
  TreeNode toFreezed() => TreeNode.group(
    name: name,
    fullPath: fullPath,
    children: children.values.map((_MutableNode c) => c.toFreezed()).toList(),
  );
}

class _MutableLeaf extends _MutableNode {
  _MutableLeaf(super.name, super.fullPath, this.key);
  final LocalizationKey key;

  @override
  TreeNode toFreezed() => TreeNode.leaf(name: name, fullPath: fullPath, localizationKey: key);
}
