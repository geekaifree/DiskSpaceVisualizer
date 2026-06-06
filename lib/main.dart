import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const DiskSpaceApp());

class DiskSpaceApp extends StatelessWidget {
  const DiskSpaceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '磁盘空间可视化', debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.amber, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.amber, useMaterial3: true, brightness: Brightness.dark),
    home: const DiskHomePage(),
  );
}

class DiskItem {
  final String name, path, type;
  final int sizeMB;
  final Color color;
  final List<DiskItem>? children;
  DiskItem({required this.name, required this.path, required this.type, required this.sizeMB, required this.color, this.children});
}

class DiskHomePage extends StatefulWidget {
  const DiskHomePage({super.key});
  @override
  State<DiskHomePage> createState() => _DiskHomePageState();
}

class _DiskHomePageState extends State<DiskHomePage> {
  late DiskItem _root;
  DiskItem? _selected;
  String _view = 'treemap';

  @override
  void initState() {
    super.initState();
    _root = DiskItem(name: 'Macintosh HD', path: '/', type: 'disk', sizeMB: 500000, color: Colors.blue, children: [
      DiskItem(name: 'Users', path: '/Users', type: 'folder', sizeMB: 280000, color: Colors.green, children: [
        DiskItem(name: 'Documents', path: '/Users/docs', type: 'folder', sizeMB: 85000, color: Colors.teal),
        DiskItem(name: 'Pictures', path: '/Users/pics', type: 'folder', sizeMB: 120000, color: Colors.orange),
        DiskItem(name: 'Music', path: '/Users/music', type: 'folder', sizeMB: 45000, color: Colors.purple),
        DiskItem(name: 'Videos', path: '/Users/videos', type: 'folder', sizeMB: 30000, color: Colors.red),
      ]),
      DiskItem(name: 'Applications', path: '/Applications', type: 'folder', sizeMB: 95000, color: Colors.indigo),
      DiskItem(name: 'System', path: '/System', type: 'folder', sizeMB: 65000, color: Colors.grey),
      DiskItem(name: 'Library', path: '/Library', type: 'folder', sizeMB: 40000, color: Colors.brown),
      DiskItem(name: 'Developer', path: '/Developer', type: 'folder', sizeMB: 20000, color: Colors.cyan),
    ]);
    _selected = _root;
  }

  String _formatSize(int mb) {
    if (mb > 1000) return '${(mb / 1000).toStringAsFixed(1)} GB';
    return '$mb MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💾 磁盘空间可视化'), centerTitle: true, actions: [
        SegmentedButton<String>(segments: const [ButtonSegment(value: 'treemap', label: Text('树图')), ButtonSegment(value: 'list', label: Text('列表'))], selected: {_view}, onSelectionChanged: (v) => setState(() => _view = v.first), style: ButtonStyle(visualDensity: VisualDensity.compact)),
      ]),
      body: Column(children: [
        // 磁盘概览
        Card(margin: const EdgeInsets.all(12), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          Row(children: [const Icon(Icons.storage, color: Colors.blue), const SizedBox(width: 8), Text(_root.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), const Spacer(), Text('${_formatSize(_root.sizeMB)} 总容量', style: const TextStyle(color: Colors.grey))]),
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.72, minHeight: 12, backgroundColor: Colors.grey.shade200, color: Colors.blue)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('已用: ${_formatSize((_root.sizeMB * 0.72).toInt())}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('可用: ${_formatSize((_root.sizeMB * 0.28).toInt())}', style: const TextStyle(fontSize: 12, color: Colors.green)),
          ]),
        ]))),
        // 选中项详情
        if (_selected != null && _selected != _root) Card(margin: const EdgeInsets.symmetric(horizontal: 12), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: _selected!.color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Center(child: Icon(_selected!.type == 'folder' ? Icons.folder : Icons.insert_drive_file, color: _selected!.color))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_selected!.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(_selected!.path, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
          Text(_formatSize(_selected!.sizeMB), style: TextStyle(fontWeight: FontWeight.bold, color: _selected!.color, fontSize: 16)),
        ]))),
        // 树图或列表
        Expanded(child: _view == 'treemap' ? _buildTreemap() : _buildList()),
      ]),
    );
  }

  Widget _buildTreemap() {
    final items = _selected?.children ?? _root.children ?? [];
    if (items.isEmpty) return const Center(child: Text('无子项目'));
    return Padding(padding: const EdgeInsets.all(12), child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8), itemCount: items.length, itemBuilder: (ctx, i) {
      final item = items[i];
      final ratio = item.sizeMB / _root.sizeMB;
      return GestureDetector(onTap: () => setState(() => _selected = item), child: Container(decoration: BoxDecoration(color: item.color.withOpacity(0.15 + ratio * 0.5), borderRadius: BorderRadius.circular(12), border: Border.all(color: _selected?.path == item.path ? item.color : Colors.transparent, width: 2)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(item.type == 'folder' ? Icons.folder : Icons.insert_drive_file, color: item.color, size: 32),
        const SizedBox(height: 8),
        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        Text(_formatSize(item.sizeMB), style: TextStyle(fontSize: 11, color: item.color)),
      ])));
    }));
  }

  Widget _buildList() {
    final items = _selected?.children ?? _root.children ?? [];
    if (items.isEmpty) return const Center(child: Text('无子项目'));
    final sorted = [...items]..sort((a, b) => b.sizeMB.compareTo(a.sizeMB));
    return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: sorted.length, itemBuilder: (ctx, i) {
      final item = sorted[i];
      final pct = item.sizeMB / _root.sizeMB;
      return Card(margin: const EdgeInsets.only(bottom: 4), child: ListTile(
        leading: Icon(item.type == 'folder' ? Icons.folder : Icons.insert_drive_file, color: item.color),
        title: Text(item.name),
        subtitle: LinearProgressIndicator(value: pct, backgroundColor: Colors.grey.shade200, color: item.color),
        trailing: Text(_formatSize(item.sizeMB), style: TextStyle(fontWeight: FontWeight.bold, color: item.color)),
        onTap: () => setState(() => _selected = item),
      ));
    });
  }
}
