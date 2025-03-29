import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart'
    if (dart.library.html) 'package:web_socket_channel/html.dart';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late Web3Client _client;
  late Credentials _credentials;
  List<dynamic> _products = <dynamic>[];
  List<dynamic> _cart = <dynamic>[];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final infuraUrl =
          'wss://rinkeby.infura.io/ws/v3/YOUR_INFURA_PROJECT_ID'; // Replace
      final privateKey =
          '0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'; // Replace
      final contractAddress =
          '0x1234567890abcdef1234567890abcdef12345678'; // Replace

      _client = Web3Client(infuraUrl, http.Client(), socketConnector: () {
        return WebSocketChannel.connect(Uri.parse(infuraUrl)).cast<String>();
      });
      _credentials = EthPrivateKey.fromHex(privateKey);

      _products = List.generate(10, (index) {
        final random = Random();
        return [
          index.toString(),
          'Product ${index + 1}',
          random.nextInt(200) + 50,
          random.nextInt(100) + 10,
          'assets/product_${(index % 3) + 1}.jpg',
        ];
      });

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
      print('Initialization error: ${e.toString()}');
    }
  }

  void _addToCart(int productId, int quantity) {
    final product = _products.firstWhere((p) => p[0] == productId.toString());
    setState(() {
      _cart.add({
        'id': product[0],
        'name': product[1],
        'price': product[2],
        'quantity': quantity,
        'image': product[4],
      });
    });
  }

  Future<void> _buyProduct(int productId, int quantity) async {
    try {
      print(
          "Simulating Buy Transaction: ProductID: $productId, Quantity: $quantity");
    } catch (e) {
      setState(() {
        _errorMessage = 'Error buying product: ${e.toString()}';
      });
      print('Buy product error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        body: Center(child: Text(_errorMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Farmer\'s Market')),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.asset(
                product[4],
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported);
                },
              ),
              title: Text(product[1]),
              subtitle: Text('Price: ₹${product[2]}, Quantity: ${product[3]}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => QuantityDialog(
                            productId: int.parse(product[0]),
                            onAddToCart: (id, qty) => _addToCart(id, qty)),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SellProductScreen()));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartScreen(cart: _cart)));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityDialog extends StatefulWidget {
  final int productId;
  final Function(int, int) onAddToCart;

  const QuantityDialog(
      {super.key, required this.productId, required this.onAddToCart});

  @override
  _QuantityDialogState createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Quantity'),
      content: TextField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Quantity'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            widget.onAddToCart(
                widget.productId, int.parse(_quantityController.text));
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<dynamic> cart;

  const CartScreen({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: ListView.builder(
        itemCount: cart.length,
        itemBuilder: (context, index) {
          final item = cart[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Image.asset(
                item[4],
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported);
                },
              ),
              title: Text(item[1]),
              subtitle:
                  Text('Price: ₹${item[2]}, Quantity: ${item['quantity']}'),
            ),
          );
        },
      ),
    );
  }
}

class SellProductScreen extends StatefulWidget {
  @override
  _SellProductScreenState createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price (₹)'),
                keyboardType: TextInputType.number),
            TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number),
            ElevatedButton(
                onPressed: getImage, child: const Text('Pick Image')),
            if (_image != null) Image.file(_image!, height: 100),
            ElevatedButton(
              onPressed: () {
                // Implement your sell product logic here, including image upload if needed.
                print("Simulating sell");
                Navigator.pop(context);
              },
              child: const Text('Sell'),
            ),
          ],
        ),
      ),
    );
  }
}
