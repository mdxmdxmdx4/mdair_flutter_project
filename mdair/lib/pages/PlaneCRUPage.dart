import 'package:flutter/material.dart';
import 'package:mdair/models/plane.dart';

import '../database_helper.dart';

class PlaneCRUPage extends StatefulWidget {
  @override
  _CRUPageState createState() => _CRUPageState();
}
Plane planeToInsert = Plane(planeId: 0, model: "", businessSeatsCapacity: 0, economySeatsCapacity: 0);
Plane planeToUpdate = Plane(planeId: 0, model: "", businessSeatsCapacity: 0, economySeatsCapacity: 0);

class _CRUPageState extends State<PlaneCRUPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final DatabaseHelper databaseHelper = DatabaseHelper.instance;
  List<Plane> _planes = [];

  final idControllerUpdate = TextEditingController();
  final modelControllerUpdate = TextEditingController();
  final businessSeatsControllerUpdate = TextEditingController();
  final economySeatsControllerUpdate = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPlanes();
  }

  void _loadPlanes() async {
    List<Plane> planes = await databaseHelper.getPlanes();
    setState(() {
      _planes = planes;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    idControllerUpdate.dispose();
    modelControllerUpdate.dispose();
    businessSeatsControllerUpdate.dispose();
    economySeatsControllerUpdate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75),
        child: AppBar(
          automaticallyImplyLeading: false,
          title: null,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Retrieve'),
              Tab(icon: Icon(Icons.add), text: 'Insert'),
              Tab(icon: Icon(Icons.edit), text: 'Update'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: _planes.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('№${_planes[index].planeId} ${_planes[index].model}'),
                subtitle: Text('B seats: ${_planes[index].businessSeatsCapacity} | R seats: ${_planes[index].economySeatsCapacity}'),
                onTap: (){
                  idControllerUpdate.text = _planes[index].planeId.toString();
                  modelControllerUpdate.text = _planes[index].model;
                  businessSeatsControllerUpdate.text = _planes[index].businessSeatsCapacity.toString();
                  economySeatsControllerUpdate.text = _planes[index].economySeatsCapacity.toString();
                  _tabController?.animateTo(2);
                },
              );
            },
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Model',
                  ),
                  onChanged: (value) {
                    planeToInsert.model = value;
                  },
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Business-class seats count',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    planeToInsert.businessSeatsCapacity = int.tryParse(value)!;
                  },
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Regular-class seats count',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    planeToInsert.economySeatsCapacity = int.tryParse(value)!;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.blueGrey
                  ),
                  onPressed: () async {
                    await databaseHelper.insertPlane(planeToInsert);
                    _loadPlanes();
                    planeToInsert = Plane(planeId: 0, model: "", businessSeatsCapacity: 0, economySeatsCapacity: 0);
                  },
                  child: Text('Add plane', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: idControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'Plane ID to update',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: modelControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'New Model',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: businessSeatsControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'Business-class seats count',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: economySeatsControllerUpdate,
                    decoration: InputDecoration(
                      labelText: 'Regular-class seats count',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blueGrey
                    ),
                    onPressed: () async {
                      planeToUpdate.model = modelControllerUpdate.text;
                      planeToUpdate.planeId = int.parse(idControllerUpdate.text);
                      planeToUpdate.economySeatsCapacity = int.parse(economySeatsControllerUpdate.text);
                      planeToUpdate.businessSeatsCapacity = int.parse(businessSeatsControllerUpdate.text);
                    await databaseHelper.updatePlane(planeToUpdate);
                    planeToUpdate = Plane(planeId: 0, model: "", businessSeatsCapacity: 0, economySeatsCapacity: 0);
                    _loadPlanes();
                    idControllerUpdate.clear();
                    modelControllerUpdate.clear();
                    businessSeatsControllerUpdate.clear();
                    economySeatsControllerUpdate.clear();
                  },
                  child: Text('Update Information', style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}

