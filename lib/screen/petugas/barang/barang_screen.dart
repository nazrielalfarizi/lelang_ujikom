import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lelang_ujikom/const/const.dart';
import 'package:lelang_ujikom/controller/barang_controller.dart';
import 'package:lelang_ujikom/screen/admin/barang/barang_screen.dart';

import '../../../controller/login_controller.dart';
import '../../../widgets/normal_text.dart';
import '../../admin/barang/edit_barang.dart';
import '../../admin/barang/tambah_barang.dart';
import '../../login_screen.dart';
import 'package:intl/intl.dart' as intl;

import 'barang_detail_screen.dart';

class BarangViewPetugas extends StatelessWidget {
  const BarangViewPetugas({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BarangController>(
        init: BarangController(),
        builder: (controller) {
          controller.viewPetugas = this;

          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Get.to(() => const AddBarang());
              },
              child: const Icon(Icons.add),
            ),
            appBar: AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              title: boldtext(text: 'Data Barang', color: darkGrey, size: 16.0),
              actions: [
                Center(
                    child: normalText(
                        text: intl.DateFormat('EEE, MMM d,' ' yy')
                            .format(DateTime.now()),
                        color: purpleColor)),
                65.widthBox,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        await Get.find<LoginController>().SignOut(context);
                        Get.offAll(() => const Login());
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        primary: Colors.red,
                        onPrimary: Colors.white,
                      ),
                      child:
                          boldtext(text: 'Log Out', color: white, size: 15.0)),
                ),
              ],
            ),
            body: Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("barang")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Text("Error");
                        if (snapshot.data == null) return Container();
                        if (snapshot.data!.docs.isEmpty) {
                          return const Text("No Data");
                        }
                        final data = snapshot.data!;
                        return ListView.builder(
                          itemCount: data.docs.length,
                          padding: EdgeInsets.zero,
                          clipBehavior: Clip.none,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> item = (data.docs[index].data()
                                as Map<String, dynamic>);
                            item["id"] = data.docs[index].id;
                            final DocumentSnapshot records =
                                snapshot.data!.docs[index];
                            return InkWell(
                              child: Card(
                                elevation: 5,
                                child: ListTile(
                                  onTap: () {
                                    Get.to(
                                        () => BarangDetailPetugas(data: item));
                                  },
                                  leading: Image.network(
                                    item["barang_image"][0],
                                    width: 120,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  title: boldtext(
                                      text: item["nama_barang"],
                                      color: fontGrey,
                                      size: 20.0),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      normalText(
                                        text: "Rp." + item["harga_awal"],
                                        color: Colors.redAccent[700],
                                      ),
                                      normalText(
                                        text: "Di Upload :" + item["tanggal"],
                                        color: darkGrey,
                                      ),
                                      item['status'] == 'Dilelang'
                                          ? normalText(
                                              text: item['status'],
                                              color: Colors.green)
                                          : normalText(
                                              text: item['status'],
                                              color: Colors.redAccent[700])
                                    ],
                                  ),
                                  trailing: VxPopupMenu(
                                    menuBuilder: () => Column(
                                      children: List.generate(
                                        popupMenuTitles.length,
                                        (i) => Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                            children: [
                                              Icon(popupMenuIcons[i]),
                                              10.widthBox,
                                              normalText(
                                                  text: popupMenuTitles[i],
                                                  color: darkGrey)
                                            ],
                                          ).onTap(() {
                                            switch (i) {
                                              case 0:
                                                Get.to(() => EditBarang(
                                                      item: item,
                                                    ));

                                                break;
                                              case 1:
                                                controller
                                                    .hapusBarang(item["id"]);
                                                VxToast.show(context,
                                                    msg: "Barang di Hapus!");
                                                break;
                                            }
                                          }),
                                        ),
                                      ),
                                    ).box.white.rounded.width(200).make(),
                                    clickType: VxClickType.singleClick,
                                    child: const Icon(Icons.more_vert_rounded),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
