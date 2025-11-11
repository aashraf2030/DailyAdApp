import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import '../../Models/chat_message.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final Dio dio;
  final String baseUrl; // مثال: "https://your-server.com/api"

  ChatCubit(this.dio, {required this.baseUrl}) : super(const ChatState());

  void addLocalMessage(ChatMessage m) {
    final updated = List<ChatMessage>.from(state.messages)..add(m);
    emit(state.copyWith(messages: updated));
  }

  Future<void> sendToAssistant(String text) async {
    if (text.trim().isEmpty || state.sending) return;

    addLocalMessage(ChatMessage(role: ChatRole.user, content: text));

    emit(state.copyWith(sending: true, error: null));
    
    // تأخير بسيط عشان يبان كأنه بيكتب (1-2 ثانية)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // الرد التلقائي
    const reply = "شكراً لتواصلك معنا! 🙏\n\n"
        "المساعد الذكي غير مفعّل حالياً في هذا التطبيق.\n\n"
        "للحصول على خدمة الذكاء الاصطناعي المتكاملة، "
        "برجاء التواصل مع الشركة لتفعيل هذه الميزة.\n\n"
        "يمكنك التواصل معنا عبر واتساب من خلال الزر الأخضر في الصفحة الرئيسية. ✨";
    
    addLocalMessage(ChatMessage(role: ChatRole.assistant, content: reply));
    emit(state.copyWith(sending: false));
    
    // الكود القديم (معطّل):
    /*
    try {
      final messagesPayload = state.messages.map((m) => m.toJson()).toList();

      final resp = await dio.post(
        "$baseUrl/chat",
        data: {"messages": messagesPayload},
        options: Options(
          headers: {"Content-Type": "application/json"},
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final reply = (resp.data?["reply"] ?? "").toString();
      if (reply.isEmpty) {
        emit(state.copyWith(sending: false, error: "لم يتم استلام رد من الخادم"));
      } else {
        addLocalMessage(ChatMessage(role: ChatRole.assistant, content: reply));
        emit(state.copyWith(sending: false));
      }
    } on DioException catch (e) {
      String errorMsg = "حدث خطأ في الاتصال";
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        errorMsg = "انتهى وقت الاتصال، حاول مرة أخرى";
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = "خطأ في الاتصال بالإنترنت";
      } else if (e.response?.statusCode == 500) {
        errorMsg = "خطأ في الخادم، حاول لاحقاً";
      }
      emit(state.copyWith(sending: false, error: errorMsg));
    } catch (e) {
      emit(state.copyWith(sending: false, error: "حدث خطأ غير متوقع"));
    }
    */
  }
}
