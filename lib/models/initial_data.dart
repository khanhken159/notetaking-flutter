import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'note.dart';

const List<LabelColor> labelColors = [
  LabelColor(
    id: 'indigo',
    name: 'Chàm dịu',
    hex: '#5C67DE',
    primaryColor: Color(0xFF5C67DE),
    backgroundColor: Color(0xFFEEF0FD),
    textColor: Color(0xFF4338CA),
    borderColor: Color(0xFFC7D2FE),
  ),
  LabelColor(
    id: 'rose',
    name: 'Hồng san hô',
    hex: '#E11D48',
    primaryColor: Color(0xFFE11D48),
    backgroundColor: Color(0xFFFFECEF),
    textColor: Color(0xFFBE123C),
    borderColor: Color(0xFFFECDD3),
  ),
  LabelColor(
    id: 'sky',
    name: 'Xanh da trời',
    hex: '#0284C7',
    primaryColor: Color(0xFF0284C7),
    backgroundColor: Color(0xFFF0F9FF),
    textColor: Color(0xFF0369A1),
    borderColor: Color(0xFFBAE6FD),
  ),
  LabelColor(
    id: 'amber',
    name: 'Hổ phách',
    hex: '#D97706',
    primaryColor: Color(0xFFD97706),
    backgroundColor: Color(0xFFFFFBEB),
    textColor: Color(0xFFB45309),
    borderColor: Color(0xFFFDE68A),
  ),
  LabelColor(
    id: 'emerald',
    name: 'Ngọc bích',
    hex: '#059669',
    primaryColor: Color(0xFF059669),
    backgroundColor: Color(0xFFECFDF5),
    textColor: Color(0xFF047857),
    borderColor: Color(0xFFA7F3D0),
  ),
  LabelColor(
    id: 'violet',
    name: 'Tím oải hương',
    hex: '#7C3AED',
    primaryColor: Color(0xFF7C3AED),
    backgroundColor: Color(0xFFF5F3FF),
    textColor: Color(0xFF6D28D9),
    borderColor: Color(0xFFDDD6FE),
  ),
  LabelColor(
    id: 'teal',
    name: 'Xanh ngọc lam',
    hex: '#0D9488',
    primaryColor: Color(0xFF0D9488),
    backgroundColor: Color(0xFFF0FDFA),
    textColor: Color(0xFF0F766E),
    borderColor: Color(0xFF99F6E4),
  ),
  LabelColor(
    id: 'stone',
    name: 'Xám ấm',
    hex: '#57534E',
    primaryColor: Color(0xFF57534E),
    backgroundColor: Color(0xFFF5F5F4),
    textColor: Color(0xFF44403C),
    borderColor: Color(0xFFE7E5E4),
  ),
];

const List<LabelColor> prototypeColors = labelColors;

LabelColor getLabelColor(String colorId) {
  return labelColors.firstWhere(
    (c) => c.id == colorId,
    orElse: () => labelColors.first,
  );
}

final List<Label> initialLabels = [
  Label(id: 'lbl-1', name: 'Cá nhân', colorId: 'rose'),
  Label(id: 'lbl-2', name: 'Học tập', colorId: 'sky'),
  Label(id: 'lbl-3', name: 'Công việc', colorId: 'indigo'),
  Label(id: 'lbl-4', name: 'Ý tưởng', colorId: 'amber'),
  Label(id: 'lbl-5', name: 'Tài chính', colorId: 'emerald'),
];

List<Note> getInitialNotes() {
  final now = DateTime.now().millisecondsSinceEpoch;
  const hour = 3600 * 1000;
  const day = 24 * hour;

  return [
    Note(
      id: 'note-1',
      title: 'Kế hoạch tuần này - Mục tiêu công việc',
      content: '',
      isChecklist: true,
      checklist: [
        ChecklistItem(id: 'c-1', text: 'Gửi báo cáo số liệu quý 4 cho anh Dũng trước 16h', completed: true),
        ChecklistItem(id: 'c-2', text: 'Hoàn thành bản thiết kế giao diện cho màn hình trang chủ', completed: true),
        ChecklistItem(id: 'c-3', text: 'Họp đồng bộ cùng nhóm phát triển lúc 10h thứ Năm', completed: false),
        ChecklistItem(id: 'c-4', text: 'Chuẩn bị tài liệu thuyết trình cho khách hàng đối tác', completed: false),
        ChecklistItem(id: 'c-5', text: 'Rà soát phản hồi từ phòng kiểm thử chất lượng', completed: false),
      ],
      labelIds: ['lbl-3'],
      isPinned: true,
      createdAt: now - 2 * day,
      updatedAt: now - 25 * 60 * 1000,
    ),
    Note(
      id: 'note-2',
      title: 'Bí quyết nấu Phở Bò gia truyền của Ngoại',
      content:
          'Ninh xương ống bò ít nhất 6 tiếng trên lửa nhỏ liu riu, vớt bọt liên tục để nước dùng trong vắt tự nhiên.\n\nGia vị thơm nướng xém qua than hoa: 2 củ hành tây, 1 nhánh gừng già đập dập, 3 hoa hồi, 1 quả thảo quả, 1 thanh quế thơm.\n\nLưu ý: Nêm nước mắm cốt ngon ở bước cuối cùng, không nêm quá sớm làm nước bị chua. Dọn kèm hành hoa thái mỏng và vài lát ớt chỉ thiên tươi.',
      isChecklist: false,
      checklist: [],
      labelIds: ['lbl-1'],
      isPinned: true,
      createdAt: now - 3 * day,
      updatedAt: now - 4 * hour,
    ),
    Note(
      id: 'note-3',
      title: 'Tóm tắt ôn tập Lịch sử - Các mốc trọng tâm',
      content:
          '1. Chiến dịch Điện Biên Phủ (1954): 56 ngày đêm khoét núi ngủ hầm, kết thúc thắng lợi vẻ vang "lừng lẫy năm châu, chấn động địa cầu".\n2. Hiệp định Giơ-ne-vơ (21/7/1954): Công nhận độc lập, chủ quyền và toàn vẹn lãnh thổ của Việt Nam.\n3. Phong trào Đồng Khởi (1960): Bước ngoặt từ thế giữ gìn lực lượng sang thế tiến công.\n\nNội dung cần chú ý: Ý nghĩa lịch sử và bài học kinh nghiệm về khối đại đoàn kết toàn dân tộc.',
      isChecklist: false,
      checklist: [],
      labelIds: ['lbl-2'],
      isPinned: true,
      createdAt: now - 5 * day,
      updatedAt: now - 1 * day,
    ),
    Note(
      id: 'note-4',
      title: 'Danh sách đồ đạc chuẩn bị du lịch Đà Lạt',
      content: '',
      isChecklist: true,
      checklist: [
        ChecklistItem(id: 'c-201', text: 'Áo len mỏng và áo khoác ấm cho buổi tối lạnh', completed: true),
        ChecklistItem(id: 'c-202', text: 'Máy ảnh du lịch và 2 thẻ nhớ dự phòng', completed: true),
        ChecklistItem(id: 'c-203', text: 'Sạc dự phòng 20.000mAh kèm cáp Type-C', completed: true),
        ChecklistItem(id: 'c-204', text: 'Thuốc say xe và xịt côn trùng', completed: false),
        ChecklistItem(id: 'c-205', text: 'Đặt trước vé xe trung chuyển sân bay Liên Khương', completed: false),
        ChecklistItem(id: 'c-206', text: 'Lưu bản đồ offline các quán cà phê ngắm hoàng hôn Tuyền Lâm', completed: false),
      ],
      labelIds: ['lbl-1'],
      isPinned: false,
      createdAt: now - 6 * day,
      updatedAt: now - 2 * day,
    ),
    Note(
      id: 'note-5',
      title: 'Ý tưởng cải tiến trải nghiệm ứng dụng đọc sách',
      content:
          '• Chế độ đọc ban đêm với ánh sáng hổ phách ấm, giảm mỏi mắt tối đa.\n• Đánh dấu đoạn trích dẫn tâm đắc và xuất ảnh nghệ thuật để chia sẻ.\n• Thống kê số trang đã đọc hàng tuần kèm bảng huy hiệu tạo động lực.\n• Tìm kiếm tức thì trong toàn bộ thư viện sách đã lưu ngoại tuyến.\n• Tích hợp từ điển tra nhanh nghĩa từ vựng chỉ với 1 chạm giữ.',
      isChecklist: false,
      checklist: [],
      labelIds: ['lbl-4', 'lbl-3'],
      isPinned: false,
      createdAt: now - 8 * day,
      updatedAt: now - 3 * day,
      audioDuration: 24,
      audioTitle: 'Ghi âm thảo luận ý tưởng',
      audioData: 'demo_voice_data',
    ),
    Note(
      id: 'note-6',
      title: 'Kế hoạch tài chính và phân bổ chi tiêu tháng này',
      content: '',
      isChecklist: true,
      checklist: [
        ChecklistItem(id: 'c-301', text: 'Tiền thuê nhà và phí quản lý chung cư', completed: true),
        ChecklistItem(id: 'c-302', text: 'Chi phí ăn uống và nhu yếu phẩm hàng ngày (35%)', completed: false),
        ChecklistItem(id: 'c-303', text: 'Trích quỹ tiết kiệm đầu tư tự động ngày 5 hàng tháng', completed: false),
        ChecklistItem(id: 'c-304', text: 'Khoản dự phòng y tế và sức khỏe', completed: false),
        ChecklistItem(id: 'c-305', text: 'Mua quà mừng sinh nhật mẹ cuối tháng', completed: false),
      ],
      labelIds: ['lbl-5'],
      isPinned: false,
      createdAt: now - 10 * day,
      updatedAt: now - 4 * day,
      isLocked: true,
    ),
    Note(
      id: 'note-7',
      title: 'Những cuốn sách hay nên đọc trong quý này',
      content:
          '1. "Hiểu Về Trái Tim" - Thầy Minh Niệm (Nuôi dưỡng sự bình an và thấu hiểu nội tâm)\n2. "Tư Duy Nhanh Và Chậm" - Daniel Kahneman (Khám phá cách não bộ đưa ra quyết định)\n3. "Súng, Vi Trùng Và Thép" - Jared Diamond (Bức tranh lịch sử phát triển của nhân loại)\n4. "Thiết Kế Cuộc Đời Đáng Sống" - Bill Burnett & Dave Evans (Vận dụng tư duy thiết kế vào sự nghiệp)',
      isChecklist: false,
      checklist: [],
      labelIds: ['lbl-2'],
      isPinned: false,
      createdAt: now - 12 * day,
      updatedAt: now - 5 * day,
    ),
    Note(
      id: 'note-8',
      title: 'Biên bản cuộc họp dự án Aurora sáng thứ Hai',
      content:
          'Thành phần tham dự: Anh Tuấn (PM), Linh (Thiết kế), Nam (Kỹ thuật), Mai (Kiểm thử).\n\nNội dung chính thống nhất:\n- Chốt thời hạn ra mắt phiên bản thử nghiệm nội bộ vào ngày 15/11.\n- Tối ưu hóa tốc độ mở ghi chú dưới 100ms trên thiết bị Android & iOS.\n- Bổ sung tính năng quản lý nhãn màu linh hoạt và tìm kiếm tức thì.\n\nPhân công việc tiếp theo:\n- Nam phụ trách đồng bộ dữ liệu ngoại tuyến.\n- Linh gửi lại toàn bộ bộ icon chuẩn trước chiều mai.',
      isChecklist: false,
      checklist: [],
      labelIds: ['lbl-3'],
      isPinned: false,
      createdAt: now - 14 * day,
      updatedAt: now - 7 * day,
    ),
  ];
}

String formatVietnameseTime(dynamic timestamp) {
  if (timestamp == null) return '';
  final int ts = timestamp is DateTime
      ? timestamp.millisecondsSinceEpoch
      : (timestamp is int ? timestamp : DateTime.now().millisecondsSinceEpoch);
  final now = DateTime.now().millisecondsSinceEpoch;
  final diff = now - ts;
  const minute = 60 * 1000;
  const hour = 60 * minute;
  const day = 24 * hour;

  if (diff < 2 * minute) {
    return 'Vừa xong';
  }
  if (diff < hour) {
    final m = (diff / minute).floor();
    return '$m phút trước';
  }
  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  if (diff < day) {
    final timeStr = DateFormat('HH:mm').format(date);
    return 'Hôm nay, $timeStr';
  }
  if (diff < 2 * day) {
    final timeStr = DateFormat('HH:mm').format(date);
    return 'Hôm qua, $timeStr';
  }
  return '${date.day} thg ${date.month}';
}
