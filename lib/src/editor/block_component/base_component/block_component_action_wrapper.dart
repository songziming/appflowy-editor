import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/renderer/block_component_action.dart';
import 'package:flutter/material.dart';

typedef BlockComponentActionBuilder = Widget Function(
  BuildContext context,
  BlockComponentActionState state,
);

typedef BlockComponentActionTrailingBuilder = Widget Function(
  BuildContext context,
  BlockComponentActionState state,
);

class BlockComponentActionWrapper extends StatefulWidget {
  const BlockComponentActionWrapper({
    super.key,
    required this.node,
    required this.child,
    required this.actionBuilder,
    this.actionTrailingBuilder,
  });

  final Node node;
  final Widget child;
  final BlockComponentActionBuilder actionBuilder;
  final BlockComponentActionTrailingBuilder? actionTrailingBuilder;

  @override
  State<BlockComponentActionWrapper> createState() =>
      _BlockComponentActionWrapperState();
}

class _BlockComponentActionWrapperState
    extends State<BlockComponentActionWrapper>
    implements BlockComponentActionState {
  final showActionsNotifier = ValueNotifier<bool>(false);

  /// 新增状态，记录鼠标悬浮状态
  /// Unlike [showActionsNotifier], this value is not affected by
  /// [forceShowBlockAction], so the trailing widget can still be hidden when
  /// the block actions are forced to be visible.
  final hoverNotifier = ValueNotifier<bool>(false);

  bool isDisposed = false;

  bool _alwaysShowActions = false;

  bool get alwaysShowActions => _alwaysShowActions;

  @override
  bool get isHovering => hoverNotifier.value;

  @override
  set alwaysShowActions(bool alwaysShowActions) {
    if (isDisposed) {
      return;
    }
    _alwaysShowActions = alwaysShowActions;
    if (_alwaysShowActions == false && showActionsNotifier.value == true) {
      showActionsNotifier.value = false;
    }
  }

  @override
  void initState() {
    super.initState();

    if (forceShowBlockAction) {
      alwaysShowActions = true;
      showActionsNotifier.value = true;
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    showActionsNotifier.dispose();
    hoverNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        hoverNotifier.value = true;
        showActionsNotifier.value = true;
      },
      onExit: (_) {
        hoverNotifier.value = false;
        showActionsNotifier.value = alwaysShowActions || false;
      },
      hitTestBehavior: HitTestBehavior.opaque,
      opaque: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: showActionsNotifier,
            builder: (context, value, child) => BlockComponentActionContainer(
              node: widget.node,
              showActions: value,
              actionBuilder: (context) => widget.actionBuilder(context, this),
            ),
          ),
          if (widget.actionTrailingBuilder != null)
            ValueListenableBuilder<bool>(
              valueListenable: hoverNotifier,
              builder: (context, isHovering, child) =>
                  widget.actionTrailingBuilder!(context, this),
            ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
