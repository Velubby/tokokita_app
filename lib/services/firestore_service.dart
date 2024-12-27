import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/user_model.dart';
import '/models/category_model.dart';
import '/models/brand_model.dart';
import '/models/team_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user data from Firestore
  Future<User> getUser(String userId) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();
    return User.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
  }

  // Save user data to Firestore
  Future<void> saveUser(User user) async {
    await _firestore.collection('users').doc(user.userId).set(user.toMap());
  }

  // Update user's teams list in Firestore
  Future<void> updateTeams(String userId, List<String> teams) async {
    if (userId.isEmpty) {
      print("Error: User ID cannot be empty.");
      return;
    }

    try {
      await _firestore.collection('users').doc(userId).update({
        'teams': teams,
      });
      print("Teams updated successfully for user: $userId");
    } catch (e) {
      print("Error updating teams: $e");
    }
  }

  Future<List<String>> getTeams(String userId) async {
    if (userId.isEmpty) {
      print("Error: User ID cannot be empty.");
      return [];
    }

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        var teams = (userDoc.data() as Map<String, dynamic>)['teams'] ?? [];
        return List<String>.from(teams);
      } else {
        print("No user document found for ID: $userId");
        return [];
      }
    } catch (e) {
      print("Error fetching teams: $e");
      return [];
    }
  }

  // Get categories based on teamId
  Future<List<Category>> getCategoriesByTeamId(String teamId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .where('teamId', isEqualTo: teamId)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  // Add a new category
  Future<void> addCategory(Category category) async {
    try {
      // Check if the category already exists
      var existingCategoryQuery = await _firestore
          .collection('categories')
          .where('name', isEqualTo: category.name)
          .where('teamId', isEqualTo: category.teamId)
          .get();

      if (existingCategoryQuery.docs.isEmpty) {
        await _firestore.collection('categories').add(category.toMap());
      } else {
        print("Category already exists!");
      }
    } catch (e) {
      print("Error adding category: $e");
    }
  }

  Stream<List<Category>> getCategoriesStream(String teamId) {
    return _firestore
        .collection('categories')
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) =>
                Category.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get brands based on teamId
  Future<List<Brand>> getBrandsByTeamId(String teamId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('brands')
          .where('teamId', isEqualTo: teamId)
          .get();

      return querySnapshot.docs
          .map((doc) =>
              Brand.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error fetching brands: $e");
      return [];
    }
  }

  // Add a new brand
  Future<void> addBrand(Brand brand) async {
    try {
      await _firestore.collection('brands').add(brand.toMap());
    } catch (e) {
      print("Error adding brand: $e");
    }
  }

  // Get the team data for a user based on their teamId
  Future<Team?> getUserTeam(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        var teamId = userDoc
            .get('teamId'); // Assuming the user document has 'teamId' field
        DocumentSnapshot teamDoc =
            await _firestore.collection('teams').doc(teamId).get();
        if (teamDoc.exists) {
          return Team.fromMap(
              teamDoc.data() as Map<String, dynamic>, teamDoc.id);
        }
      }
    } catch (e) {
      print("Error fetching team: $e");
    }
    return null;
  }
}
