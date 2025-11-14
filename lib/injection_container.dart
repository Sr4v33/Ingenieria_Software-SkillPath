// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Core
import 'core/network/network_info.dart';

// Data
import 'data/datasources/remote/firestore_datasource.dart';
import 'data/datasources/remote/firebase_auth_datasource.dart';
import 'data/datasources/local/shared_prefs_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/progress_repository_impl.dart';

// Domain
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/progress_repository.dart';
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';
import 'domain/usecases/learning/load_learning_path_usecase.dart';
import 'domain/usecases/learning/complete_node_usecase.dart';
import 'domain/usecases/learning/mark_content_viewed_usecase.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ========== External ==========
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => Connectivity());

  // ========== Core ==========
  sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(connectivity: sl()),
  );

  // ========== Data Sources ==========
  sl.registerLazySingleton<FirestoreDataSource>(
        () => FirestoreDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<FirebaseAuthDataSource>(
        () => FirebaseAuthDataSourceImpl(
      auth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<SharedPrefsDataSource>(
        () => SharedPrefsDataSourceImpl(sharedPreferences: sl()),
  );

  // ========== Repositories ==========
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(dataSource: sl()),
  );

  sl.registerLazySingleton<ProgressRepository>(
        () => ProgressRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ========== Use Cases ==========
  // Auth
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // Learning
  sl.registerLazySingleton(() => LoadLearningPathUseCase(sl()));
  sl.registerLazySingleton(() => CompleteNodeUseCase(sl()));
  sl.registerLazySingleton(() => MarkContentViewedUseCase(sl()));
}