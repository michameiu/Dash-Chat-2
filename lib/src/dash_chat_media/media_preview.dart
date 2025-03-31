part of '../../dash_chat_2.dart';

class MediaPreview extends StatelessWidget {
  final MediaController controller;

  const MediaPreview({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentMessage = controller.currentChatMessage.value;
      if (currentMessage?.medias == null || currentMessage!.medias!.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(
            top: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Attachments (${currentMessage.medias!.length})',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: controller.clearMedia,
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: currentMessage.medias!.length,
                itemBuilder: (context, index) {
                  final media = currentMessage.medias![index];
                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Stack(
                      children: [
                        if (media.type == MediaType.image)
                          ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 30,
                              )
                              //  Image.network(
                              //   media.url,
                              //   fit: BoxFit.cover,
                              //   width: double.infinity,
                              //   height: double.infinity,
                              // ),
                              )
                        else if (media.type == MediaType.video)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                        else if (media.type == MediaType.audio)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.audiotrack,
                              color: Colors.white,
                              size: 30,
                            ),
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.insert_drive_file,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => controller.removeMedia(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
