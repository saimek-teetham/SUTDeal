import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

// --- Data Models ---

enum ProductStatus { active, reserved, sold }

class Product {
  final int id;
  final String title;
  final double price;
  final String category;
  final String subcategory;
  final String description;
  final String seller;
  final bool isMine;
  ProductStatus status;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.seller,
    this.isMine = false,
    this.status = ProductStatus.active,
  });
}

class ChatMessage {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
  });
}

class ChatSession {
  final int id;
  final int productId;
  final String productTitle;
  final String otherUser;
  final List<ChatMessage> messages;
  String lastMessage;

  ChatSession({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.otherUser,
    required this.messages,
    required this.lastMessage,
  });
}

// --- Main App Configuration ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUTDeal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF20B2AA),
          primary: const Color(0xFF20B2AA),
          secondary: const Color(0xFFFF6B6B),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF20B2AA),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  
  // --- Filter State ---
  String _selectedCategory = 'All'; 
  String _selectedSubcategory = 'All'; // NEW: Subcategory Filter State
  String _searchQuery = '';
  
  final TextEditingController _searchController = TextEditingController();

  // --- Category & Subcategory Data ---
  final Map<String, List<String>> _categoryMap = {
    'Textbooks': ['Math', 'Science', 'Engineering', 'HASS', 'Arts'],
    'Electronics': ['Phones', 'Laptops', 'Tablets', 'Chargers', 'Audio'],
    'Furniture': ['Desks', 'Chairs', 'Lamps', 'Shelves'],
    'Clothes': ['Men', 'Women', 'Unisex', 'Shoes', 'Bags'],
    'Stationery': ['Pens', 'Notebooks', 'Calculators', 'Art Supplies'],
    'Others': ['Sports', 'Music', 'Tickets', 'Misc'],
  };

  // --- Initial Data ---
  final List<Product> _products = [
    Product(id: 1, title: 'Calculus Textbook', price: 25, category: 'Textbooks', subcategory: 'Math', description: 'Good condition, used for 1 term', seller: 'Alice'),
    Product(id: 2, title: 'iPhone Charger', price: 10, category: 'Electronics', subcategory: 'Chargers', description: 'Brand new, never used', seller: 'Bob'),
    Product(id: 3, title: 'Study Desk', price: 50, category: 'Furniture', subcategory: 'Desks', description: 'Solid wood, barely used', seller: 'Charlie'),
    Product(id: 4, title: 'Winter Jacket', price: 30, category: 'Clothes', subcategory: 'Men', description: 'Size M, warm and cozy', seller: 'David'),
  ];

  final List<ChatSession> _chats = [];

  String getCategoryEmoji(String category) {
    switch (category) {
      case 'Textbooks': return '📚';
      case 'Electronics': return '📱';
      case 'Furniture': return '🪑';
      case 'Clothes': return '👕';
      case 'Stationery': return '✏️';
      default: return '📦';
    }
  }

  // --- Logic Methods ---

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addNewProduct(Product product) {
    setState(() {
      _products.add(product);
    });
  }

  void _deleteProduct(int id) {
    setState(() {
      _products.removeWhere((p) => p.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item deleted.')),
    );
  }

  void _updateProductStatus(int id, ProductStatus newStatus) {
    setState(() {
      final product = _products.firstWhere((p) => p.id == id);
      product.status = newStatus;
    });
  }

  void _startChat(Product product) {
    var existingChat = _chats.where((c) => c.productId == product.id).firstOrNull;

    if (existingChat == null) {
      existingChat = ChatSession(
        id: _chats.length + 1,
        productId: product.id,
        productTitle: product.title,
        otherUser: product.seller,
        messages: [],
        lastMessage: 'No messages yet',
      );
      setState(() {
        _chats.add(existingChat!);
      });
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chat: existingChat!, 
          onMessageSent: _updateChatLastMessage
        ),
      ),
    );
  }

  void _updateChatLastMessage(int chatId, String message) {
    setState(() {
      final index = _chats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        _chats[index].lastMessage = message;
      }
    });
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int count = (width / 220).floor(); 
    return count.clamp(2, 6);
  }

  // --- Modal & Dialog Builders ---

  void _showPostItemDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    
    // Default selections
    String selectedCat = _categoryMap.keys.first;
    String selectedSub = _categoryMap[selectedCat]!.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Post Item for Sale'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Item Title', hintText: 'e.g., Calculus Textbook'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price (SGD)', hintText: '20'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  
                  // Main Category Dropdown
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCat,
                        isDense: true,
                        isExpanded: true,
                        items: _categoryMap.keys.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedCat = val!;
                            // Reset subcategory when main category changes
                            selectedSub = _categoryMap[selectedCat]!.first;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Subcategory Dropdown (Dependent)
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Subcategory', border: OutlineInputBorder()),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSub,
                        isDense: true,
                        isExpanded: true,
                        items: _categoryMap[selectedCat]!.map((s) {
                          return DropdownMenuItem(value: s, child: Text(s));
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedSub = val!;
                          });
                        },
                      ),
                    ),
                  ),

                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty && priceController.text.isNotEmpty) {
                    final newProduct = Product(
                      id: _products.length + 1,
                      title: titleController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      category: selectedCat,
                      subcategory: selectedSub,
                      description: descController.text,
                      seller: 'You',
                      isMine: true,
                    );
                    _addNewProduct(newProduct);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item posted successfully! 🎉')),
                    );
                  }
                },
                child: const Text('Post Item'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getCategoryEmoji(product.category),
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                  if (product.status == ProductStatus.reserved)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "RESERVED",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32, letterSpacing: 2),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(product.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                  Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    label: Text('${product.category} > ${product.subcategory}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide.none,
                  ),
                  const SizedBox(width: 10),
                  Text('Seller: ${product.seller}', style: const TextStyle(color: Colors.grey)),
                  if (product.status == ProductStatus.sold)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text('(SOLD)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(product.description, style: const TextStyle(fontSize: 16, height: 1.5)),
              const Spacer(),
              if (!product.isMine && product.status != ProductStatus.sold)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _startChat(product);
                    },
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Chat with Seller'),
                  ),
                ),
               if (product.isMine)
                const Center(child: Text("This is your listing", style: TextStyle(color: Colors.grey))),
            ],
          ),
        );
      },
    );
  }

  // --- Views ---

  Widget _buildBrowseView() {
    // 1. FILTER LOGIC
    final filteredProducts = _products.where((p) {
      // Main Category Check
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      
      // Subcategory Check (NEW)
      final matchesSubcategory = _selectedSubcategory == 'All' || p.subcategory == _selectedSubcategory;

      final isNotSold = p.status != ProductStatus.sold;
      final searchLower = _searchQuery.toLowerCase();
      final matchesSearch = p.title.toLowerCase().contains(searchLower) || 
                            p.description.toLowerCase().contains(searchLower);

      return matchesCategory && matchesSubcategory && isNotSold && matchesSearch;
    }).toList();

    final int crossAxisCount = _calculateCrossAxisCount(context);
    final List<String> filterCategories = ['All', ..._categoryMap.keys];

    // Get subcategories for currently selected main category
    List<String> currentSubcategories = [];
    if (_selectedCategory != 'All' && _categoryMap.containsKey(_selectedCategory)) {
      currentSubcategories = ['All', ..._categoryMap[_selectedCategory]!];
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ) 
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // 2. MAIN CATEGORY FILTER
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: filterCategories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedCategory = cat;
                      _selectedSubcategory = 'All'; // Reset subcategory when main changes
                    });
                  },
                  selectedColor: Theme.of(context).colorScheme.primary,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              );
            }).toList(),
          ),
        ),

        // 3. SUB-CATEGORY FILTER (Only visible if a Main Category is selected)
        if (currentSubcategories.isNotEmpty)
          Container(
            color: Colors.grey.withValues(alpha: 0.1), // Slight background to distinguish
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: currentSubcategories.map((sub) {
                  final isSelected = _selectedSubcategory == sub;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(sub),
                      selected: isSelected,
                      // Smaller size for subcategories
                      visualDensity: VisualDensity.compact,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedSubcategory = sub;
                        });
                      },
                      selectedColor: Theme.of(context).colorScheme.secondary, // Different color
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        
        // Grid
        Expanded(
          child: filteredProducts.isEmpty 
          ? const Center(
              child: Text("No items found", style: TextStyle(color: Colors.grey, fontSize: 16)),
            )
          : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return _buildProductCard(product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyListingsView() {
    final myProducts = _products.where((p) => p.isMine).toList();
    final int crossAxisCount = _calculateCrossAxisCount(context);

    if (myProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No listings yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Tap the + button to create your first listing!'),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: myProducts.length,
      itemBuilder: (context, index) {
        return _buildProductCard(myProducts[index]);
      },
    );
  }

  Widget _buildChatsView() {
    if (_chats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No chats yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Start chatting with sellers!'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _chats.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              child: const Text('💬'),
            ),
            title: Text(chat.productTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chat.otherUser, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            onTap: () {
               Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    chat: chat, 
                    onMessageSent: _updateChatLastMessage
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => _showProductDetails(product),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: product.isMine 
                            ? [const Color(0xFFf093fb), const Color(0xFFf5576c)]
                            : [const Color(0xFF667eea), const Color(0xFF764ba2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(getCategoryEmoji(product.category), style: const TextStyle(fontSize: 40)),
                    ),
                  ),
                  if (product.status == ProductStatus.reserved)
                    Container(
                      color: Colors.black.withValues(alpha: 0.6),
                      child: const Center(
                        child: Text(
                          "RESERVED",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                      ),
                    ),
                  if (product.status == ProductStatus.sold)
                    Container(
                      color: Colors.white.withValues(alpha: 0.8),
                      child: const Center(
                        child: Text(
                          "SOLD",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 2),
                        ),
                      ),
                    ),
                  if (product.isMine)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'delete') {
                            _deleteProduct(product.id);
                          } else if (value == 'reserved') {
                            _updateProductStatus(product.id, ProductStatus.reserved);
                          } else if (value == 'active') {
                            _updateProductStatus(product.id, ProductStatus.active);
                          } else if (value == 'sold') {
                            _updateProductStatus(product.id, ProductStatus.sold);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          if (product.status != ProductStatus.sold)
                            PopupMenuItem<String>(
                              value: product.status == ProductStatus.reserved ? 'active' : 'reserved',
                              child: Text(product.status == ProductStatus.reserved ? 'Mark as Active' : 'Mark as Reserved'),
                            ),
                          if (product.status != ProductStatus.sold)
                            const PopupMenuItem<String>(
                              value: 'sold',
                              child: Text('Mark as Sold'),
                            ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete Listing', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text('\$${product.price}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(product.subcategory, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                      if (product.isMine)
                         Text(
                          product.status == ProductStatus.sold ? 'Sold' : (product.status == ProductStatus.reserved ? 'Reserved' : 'Active'),
                          style: TextStyle(
                            color: product.status == ProductStatus.sold ? Colors.red : Colors.green, 
                            fontSize: 10,
                            fontWeight: FontWeight.bold
                          )
                        )
                      else
                        Text(product.seller, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 SUTDeal', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildBrowseView(),
          _buildMyListingsView(),
          _buildChatsView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: _showPostItemDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'My Items',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
        ],
      ),
    );
  }
}

// --- Chat Screen ---

class ChatScreen extends StatefulWidget {
  final ChatSession chat;
  final Function(int, String) onMessageSent;

  const ChatScreen({super.key, required this.chat, required this.onMessageSent});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text;
    setState(() {
      widget.chat.messages.add(ChatMessage(
        text: text,
        isSentByMe: true,
        timestamp: DateTime.now(),
      ));
      widget.onMessageSent(widget.chat.id, text);
    });
    _controller.clear();
    _scrollToBottom();

    // Simulate Auto-Reply
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        final responses = [
          "Sure! When can we meet?",
          "Yes, it's still available!",
          "Can you do a bit lower?",
          "I'm at campus now if you want to collect!"
        ];
        final response = (responses..shuffle()).first;
        
        setState(() {
          widget.chat.messages.add(ChatMessage(
            text: response,
            isSentByMe: false,
            timestamp: DateTime.now(),
          ));
          widget.onMessageSent(widget.chat.id, response);
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.productTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.chat.messages.isEmpty 
            ? const Center(child: Text("Start the conversation!", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: widget.chat.messages.length,
              itemBuilder: (context, index) {
                final msg = widget.chat.messages[index];
                return Align(
                  alignment: msg.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isSentByMe 
                          ? Theme.of(context).colorScheme.primary 
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: msg.isSentByMe ? Radius.zero : null,
                        bottomLeft: !msg.isSentByMe ? Radius.zero : null,
                      ),
                      boxShadow: [
                        if (!msg.isSentByMe)
                          BoxShadow(color: Colors.grey.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))
                      ]
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.isSentByMe ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}