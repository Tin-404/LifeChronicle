import SwiftUI

class RecordStore: ObservableObject {
    @Published var records: [Record] = []

    // MARK: - Persistence

    private static let dataFileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("records.json")
    }()

    init() {
        load()
    }

    private func load() {
        let url = Self.dataFileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            // First launch — seed sample data
            records = Self.sampleData
            save()
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            records = try decoder.decode([Record].self, from: data)
        } catch {
            print("⚠️ Failed to load records: \(error.localizedDescription)")
            records = Self.sampleData
        }
    }

    private func save() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(records)
            try data.write(to: Self.dataFileURL, options: .atomic)
        } catch {
            print("⚠️ Failed to save records: \(error.localizedDescription)")
        }
    }

    // MARK: - Sample Data (first launch only)

    private static let sampleData: [Record] = [
        Record(
            type: .diary,
            content: "今天天气真好，去公园散步了一下午，看到了很美的日落。",
            createdAt: Date().addingTimeInterval(-86400),
            mood: "😊"
        ),
        Record(
            type: .diary,
            content: "读完了那本一直想读的书，感触良多，记录一下心得。",
            createdAt: Date().addingTimeInterval(-172800),
            mood: "😌"
        ),
        Record(
            type: .diary,
            content: "和朋友一起吃了一顿超棒的晚餐，聊了很多以前的事。",
            createdAt: Date().addingTimeInterval(-259200),
            mood: "🤩"
        ),
        Record(
            type: .photo,
            content: "夕阳下的海边，金色的波浪一层一层打在沙滩上。",
            createdAt: Date().addingTimeInterval(-86400),
            mood: "😌"
        ),
        Record(
            type: .photo,
            content: "城市夜景，霓虹灯倒映在雨后的街道上。",
            createdAt: Date().addingTimeInterval(-172800),
            mood: "🤩"
        ),
        Record(
            type: .photo,
            content: "春天的樱花开了，整条街都是粉色的。",
            createdAt: Date().addingTimeInterval(-259200),
            mood: "😊"
        ),
        Record(
            type: .film,
            content: "周末Vlog：从早午餐开始，记录了一整天的悠闲生活。",
            createdAt: Date().addingTimeInterval(-86400),
            mood: "🤩"
        ),
        Record(
            type: .film,
            content: "旅行短片：三天两夜的京都之旅，神社、枫叶与抹茶。",
            createdAt: Date().addingTimeInterval(-432000),
            mood: "😌"
        ),
        Record(
            type: .film,
            content: "早餐日记：连续七天不重样的早餐记录。",
            createdAt: Date().addingTimeInterval(-604800),
            mood: "😊"
        )
    ]

    // MARK: - Queries

    func records(of type: RecordType) -> [Record] {
        records
            .filter { $0.type == type }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func count(of type: RecordType) -> Int {
        records.filter { $0.type == type }.count
    }

    // MARK: - Mutations

    func addDiary(content: String, mood: String?) {
        let record = Record(
            type: .diary,
            content: content,
            createdAt: Date(),
            mood: mood
        )
        records.insert(record, at: 0)
        save()
    }

    func addPhoto(content: String, mood: String?, image: UIImage) {
        let imageUrl = saveImageToDocuments(image)
        let record = Record(
            type: .photo,
            content: content,
            createdAt: Date(),
            mood: mood,
            imageUrl: imageUrl
        )
        records.insert(record, at: 0)
        save()
    }

    func addFilm(content: String, mood: String?, images: [UIImage]) {
        let imagePaths = images.compactMap { saveImageToDocuments($0) }
        let record = Record(
            type: .film,
            content: content,
            createdAt: Date(),
            mood: mood,
            images: imagePaths
        )
        records.insert(record, at: 0)
        save()
    }

    func deleteRecord(_ record: Record) {
        // Remove associated image files
        let imagesDir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Images", isDirectory: true)

        for path in record.images ?? [] {
            if let url = URL(string: path) {
                try? FileManager.default.removeItem(at: url)
            }
        }
        if let imageUrl = record.imageUrl,
           let url = URL(string: imageUrl) {
            try? FileManager.default.removeItem(at: url)
        }

        records.removeAll { $0.id == record.id }
        save()
    }

    // MARK: - Image Storage

    func loadImage(at path: String) -> UIImage? {
        guard let url = URL(string: path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    private func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let imagesDir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Images", isDirectory: true)
        try? FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = imagesDir.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            return fileURL.absoluteString
        } catch {
            return nil
        }
    }
}
