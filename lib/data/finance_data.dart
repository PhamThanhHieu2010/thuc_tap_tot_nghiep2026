class FinanceData {
  // KHO DỮ LIỆU TRI THỨC TÀI CHÍNH (OFFLINE V2 - EXTENDED)
  // Được thiết kế để bắt dính mọi câu hỏi của khách hàng khi mất mạng
  
  static final List<Map<String, dynamic>> knowledgeBase = [
    // ==================================================
    // 1. QUẢN LÝ TÀI CHÍNH CÁ NHÂN (CƠ BẢN & NÂNG CAO)
    // ==================================================
    {
      "keywords": ["quy tắc 50/30/20", "chia tiền", "phân bổ lương", "chia thu nhập", "công thức quản lý", "lương về"],
      "answer": "Quy tắc 50/30/20 là kim chỉ nam: \n- 50% Nhu cầu thiết yếu (Tiền nhà, ăn, điện nước).\n- 30% Sở thích cá nhân (Mua sắm, giải trí).\n- 20% Tiết kiệm & Đầu tư.\nHãy thử áp dụng ngay khi lương về!"
    },
    {
      "keywords": ["6 chiếc lọ", "6 hũ", "jars", "chia hũ", "t harv eker", "phương pháp 6"],
      "answer": "Phương pháp 6 hũ (JARS) giúp bạn cân bằng cuộc sống:\n1. Thiết yếu (55%)\n2. Tiết kiệm dài hạn (10%)\n3. Giáo dục (10%)\n4. Hưởng thụ (10%)\n5. Tự do tài chính (10%)\n6. Từ thiện (5%)"
    },
    {
      "keywords": ["kakeibo", "nhật bản", "sổ chi tiêu", "ghi chép tay"],
      "answer": "Kakeibo là nghệ thuật tiết kiệm của người Nhật. Cốt lõi là ghi chép mọi thứ và tự hỏi: 'Tôi có thực sự cần món này không?'. Việc bạn dùng App này chính là Kakeibo thời đại số đấy!"
    },
    {
      "keywords": ["tiết kiệm", "dư tiền", "để dành", "heo đất", "tích lũy", "giữ tiền", "làm giàu", "không giữ được tiền"],
      "answer": "Mẹo tiết kiệm xương máu: Hãy 'trả cho mình trước' (trích 10-20% lương vào quỹ tiết kiệm ngay khi nhận được). Đừng đợi tiêu dư rồi mới tiết kiệm, vì sẽ chẳng bao giờ dư đâu!"
    },
    {
      "keywords": ["quỹ khẩn cấp", "dự phòng", "ốm đau", "thất nghiệp", "rủi ro"],
      "answer": "Quỹ khẩn cấp là bắt buộc! Bạn cần để dành số tiền đủ sống từ 3-6 tháng trong tài khoản ngân hàng (có thể rút ngay). Nó giúp bạn an tâm khi mất việc hoặc ốm đau."
    },

    // ==================================================
    // 2. ĐẦU TƯ & TĂNG TRƯỞNG
    // ==================================================
    {
      "keywords": ["đầu tư", "sinh lời", "tiền đẻ ra tiền", "kênh đầu tư", "lợi nhuận", "chứng khoán", "coin"],
      "answer": "Đầu tư giúp chống lạm phát.\n- An toàn: Gửi tiết kiệm (5-6%), Vàng.\n- Rủi ro vừa: Quỹ mở, Trái phiếu.\n- Rủi ro cao/Lợi nhuận cao: Cổ phiếu, Bất động sản.\nLời khuyên: Chỉ đầu tư vào thứ bạn thực sự hiểu."
    },
    {
      "keywords": ["lãi kép", "kỳ quan", "lãi mẹ đẻ lãi con", "lãi suất kép", "sức mạnh thời gian"],
      "answer": "Lãi kép là chìa khóa của sự giàu có. Công thức: A = P(1+r)^n. \nVí dụ: Mỗi tháng để dành 2 triệu, lãi 10%/năm, sau 20 năm bạn có 1.5 tỷ (trong đó gốc chỉ 480tr). Hãy bắt đầu sớm!"
    },
    {
      "keywords": ["lạm phát", "mất giá", "bão giá", "tiền mất giá"],
      "answer": "Lạm phát làm tiền của bạn 'bốc hơi' theo thời gian. Để thắng lạm phát, đừng để quá nhiều tiền mặt. Hãy học cách đầu tư hoặc gửi tiết kiệm dài hạn."
    },

    // ==================================================
    // 3. CẮT GIẢM CHI TIÊU (MẸO HAY)
    // ==================================================
    {
      "keywords": ["ăn uống", "trà sữa", "cà phê", "nhậu", "ăn hàng", "tiền ăn", "starbucks"],
      "answer": "Chi phí ăn uống nên dưới 30% thu nhập. Mẹo nhỏ: Tự nấu ăn, mang cơm đi làm, và quy định chỉ uống trà sữa/cà phê sang chảnh 1 lần/tuần."
    },
    {
      "keywords": ["mua sắm", "shopping", "quần áo", "shopee", "tiki", "lazada", "sale", "giảm giá", "chốt đơn", "nghiện mua"],
      "answer": "Mẹo cai nghiện mua sắm:\n1. Quy tắc 24h (Thích món gì hãy chờ 24h sau mới mua).\n2. Hủy theo dõi các shop.\n3. Tính giá món đồ ra giờ làm việc (Ví dụ: Cái áo này tốn 3 ngày làm việc, có đáng không?)."
    },
    {
      "keywords": ["điện", "nước", "hóa đơn", "tiền điện", "tiền nước", "internet", "điều hòa"],
      "answer": "Giảm hóa đơn tiện ích: Rút phích cắm khi không dùng, dùng bóng đèn LED, chỉnh điều hòa 26 độ kết hợp quạt. Dùng tính năng 'Hóa đơn' trong App để theo dõi biến động."
    },
    {
      "keywords": ["xăng", "xe", "đi lại", "grab", "taxi", "bảo dưỡng", "đi lại"],
      "answer": "Tiết kiệm đi lại: Bảo dưỡng xe định kỳ (lốp non tốn xăng), đi xe ghép hoặc xe bus. Nếu quãng đường < 2km, đi bộ là tốt nhất cho ví và sức khỏe."
    },

    // ==================================================
    // 4. NỢ NẦN & TÍN DỤNG
    // ==================================================
    {
      "keywords": ["nợ", "vay tiền", "mượn tiền", "trả góp", "lãi vay", "bể nợ", "trả nợ", "áp lực"],
      "answer": "Nguyên tắc xử lý nợ: \n1. Tuyết lăn (Snowball): Trả khoản nợ nhỏ nhất trước để lấy động lực.\n2. Lãi suất cao: Trả khoản lãi cao nhất trước.\nTuyệt đối không 'vay nóng' để trả nợ!"
    },
    {
      "keywords": ["thẻ tín dụng", "credit card", "quẹt thẻ", "visa", "mastercard"],
      "answer": "Thẻ tín dụng là con dao 2 lưỡi. \n- Lợi: Tiêu trước trả sau, tích điểm.\n- Hại: Lãi suất cắt cổ nếu chậm trả.\nLuôn thanh toán 100% dư nợ cuối kỳ. Nếu không kiểm soát được, hãy cắt thẻ!"
    },

    // ==================================================
    // 5. SỰ KIỆN ĐỜI SỐNG
    // ==================================================
    {
      "keywords": ["mua nhà", "chung cư", "bất động sản", "an cư", "đất"],
      "answer": "Mua nhà cần vốn đối ứng ít nhất 30-50%. Tiền trả góp hàng tháng không nên quá 30% thu nhập để tránh áp lực. Đừng mua nhà quá sớm nếu tài chính chưa vững."
    },
    {
      "keywords": ["mua xe", "ô tô", "xe hơi", "xe máy", "bốn bánh"],
      "answer": "Ô tô là tiêu sản (trừ khi dùng kinh doanh). Chi phí nuôi xe (xăng, gửi, bảo dưỡng...) khoảng 5-10 triệu/tháng. Hãy cân nhắc kỹ: Bạn mua vì nhu cầu hay vì sĩ diện?"
    },
    {
      "keywords": ["kết hôn", "đám cưới", "lấy vợ", "lấy chồng", "thành gia lập thất"],
      "answer": "Đám cưới tốn kém đấy! Hãy tạo mục tiêu tiết kiệm 'Đám cưới' trong App ngay từ bây giờ. Ngân sách trung bình 100-300 triệu tùy quy mô. Đừng vay nợ để làm đám cưới to."
    },
    {
      "keywords": ["sinh con", "em bé", "bỉm sữa", "nuôi con", "mang thai"],
      "answer": "Nuôi con là chặng đường dài. Hãy chuẩn bị quỹ sinh nở (20-30tr) và quỹ nuôi con. Chi phí bỉm sữa tháng đầu rất tốn kém, hãy tận dụng đồ cũ từ người thân."
    },

    // ==================================================
    // 6. HƯỚNG DẪN SỬ DỤNG APP (SUPPORT)
    // ==================================================
    {
      "keywords": ["thêm giao dịch", "nhập tiền", "ghi chép", "dấu cộng", "cách dùng", "nhập liệu"],
      "answer": "Bấm nút (+) màu xanh to ở giữa màn hình chính -> Nhập số tiền -> Chọn Thu/Chi -> Chọn Danh mục -> Bấm Lưu. Rất đơn giản!"
    },
    {
      "keywords": ["ví gia đình", "nhóm", "chung", "family", "vợ chồng", "quỹ chung"],
      "answer": "Tính năng Ví gia đình cho phép vợ chồng cùng quản lý. Vào 'Cài đặt' -> 'Ví Gia Đình'. Người tạo sẽ có mã chia sẻ, người kia nhập mã để tham gia."
    },
    {
      "keywords": ["xuất excel", "báo cáo", "in sao kê", "csv", "file", "gửi mail"],
      "answer": "Vào Tab 'Cài đặt' -> Chọn 'Xuất dữ liệu Excel'. App sẽ tạo file báo cáo chi tiết để bạn gửi qua Email hoặc Zalo."
    },
    {
      "keywords": ["quên mật khẩu", "pass", "đổi mật khẩu", "reset", "mất pass"],
      "answer": "Nếu quên mật khẩu, ở màn hình Đăng nhập hãy bấm 'Quên mật khẩu?'. Mã xác nhận sẽ được gửi về email của bạn."
    },

    // ==================================================
    // 7. GIAO TIẾP XÃ GIAO (CHATBOT FEELING)
    // ==================================================
    {
      "keywords": ["xin chào", "hello", "hi", "chào", "bạn là ai", "alo", "ê", "có ai không"],
      "answer": "Chào bạn! 👋 Tôi là Trợ lý Tài chính Smart Manager. Tôi có thể giúp bạn phân tích ví tiền hoặc tư vấn tài chính (Online & Offline)."
    },
    {
      "keywords": ["cảm ơn", "thank", "ok", "tốt", "hay quá", "tuyệt vời", "giỏi"],
      "answer": "Không có chi! Rất vui được hỗ trợ bạn. Hãy nhớ ghi chép chi tiêu đều đặn nhé! 😉"
    },
    {
      "keywords": ["buồn", "chán", "hết tiền", "nghèo", "khổ", "stress"],
      "answer": "Đừng nản lòng! Tài chính là cuộc đua marathon, không phải chạy nước rút. Hãy bắt đầu kiểm soát từ những khoản nhỏ nhất, tình hình sẽ khá lên thôi! 💪"
    },
    {
      "keywords": ["ngu", "dốt", "kém", "sai", "chán", "tệ", "bot ngu"],
      "answer": "Hic, xin lỗi nếu làm bạn thất vọng 😢. Tôi đang học hỏi mỗi ngày. Bạn hãy thử hỏi lại bằng từ khóa ngắn gọn hơn xem sao?"
    }
  ];
}