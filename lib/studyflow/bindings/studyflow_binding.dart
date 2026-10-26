import 'package:get/get.dart';
import '../controllers/studyflow_controllers.dart';
import '../repositories/studyflow_repository.dart';
import '../services/local_store.dart';
import '../services/studyflow_api.dart';

class StudyFlowBinding extends Bindings {
  @override void dependencies() {
    Get.put(StudyFlowApi(), permanent: true);
    Get.put(const LocalStore(), permanent: true);
    Get.put(StudyFlowRepository(Get.find(), Get.find()), permanent: true);
    final auth = Get.put(AuthController(Get.find()), permanent: true);
    Get.put(ResourcesController(Get.find()), permanent: true);
    Get.put(TasksController(Get.find(), auth), permanent: true);
    Get.put(AssistantController(Get.find(), auth), permanent: true);
    Get.put(NavigationController(), permanent: true);
  }
}
