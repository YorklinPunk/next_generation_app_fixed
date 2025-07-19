import '../db/mongo_database.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<UserModel?> login(String username, String password) async {
    print("Intentando iniciar sesión con usuario: $username");
    print("Contraseña: $password");
    
    final hashedPassword = MongoDatabase.encriptarPassword(password);

    final userMap = await MongoDatabase.userCollection.findOne({
      'username': username,
      'password': hashedPassword,
      'state': 1,
    });

    if (userMap != null) {
      return UserModel.fromMap(userMap);
    } else {
      return null;
    }
  }
}
