import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

import '../classes/rocket_info.dart';
import '../classes/dragon_info.dart';
import '../classes/vehicle.dart';
import 'vehicle_cell.dart';

class VehicleList extends StatelessWidget {
  final String rocketUrl, dragonUrl;

  VehicleList({this.rocketUrl, this.dragonUrl});

  Future fetchVehicles() async {
    final rocketResponse = await http.get(rocketUrl);
    final capsuleResponse = await http.get(dragonUrl);
    List vehicleList = List();

    List rocketJson = json.decode(rocketResponse.body);
    List capsuleJson = json.decode(capsuleResponse.body);

    vehicleList.addAll(
        rocketJson.map((rocket) => RocketInfo.fromJson(rocket)).toList());
    vehicleList.addAll(
        capsuleJson.map((capsule) => DragonInfo.fromJson(capsule)).toList());

    return vehicleList;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: fetchVehicles(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              if (!snapshot.hasError) {
                final List vehicles = snapshot.data;
                return ListView.builder(
                  key: PageStorageKey(rocketUrl),
                  padding: const EdgeInsets.all(8.0),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    if (index == 0)
                      return Column(
                        children: <Widget>[
                          Text("Rockets"),
                          VehicleCell(rocket: vehicles[index])
                        ],
                      );

                    if (vehicles[index - 1].runtimeType !=
                        vehicles[index].runtimeType)
                      return Column(
                        children: <Widget>[
                          Text("Dragons"),
                          VehicleCell(dragon: vehicles[index])
                        ],
                      );

                    return VehicleCell(
                      rocket: (vehicles[index] is RocketInfo)
                          ? vehicles[index]
                          : null,
                      dragon: (vehicles[index] is DragonInfo)
                          ? vehicles[index]
                          : null,
                    );
                  },
                );
              } else
                return const Text("Couldn't connect to server...");
          }
        },
      ),
    );
  }
}