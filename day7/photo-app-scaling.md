1.  Assumptions

The following assumptions are used to estimate the system's workload:

SnapShare has 10 million registered users.
10% of registered users are active each day.
Each daily active user uploads one photo per day.
Each daily active user views 50 feed pages per day.
Each original photo is 2 MB.
Each photo has one thumbnail of 50 KB.
A day has 86,400 seconds, and a year has 365 days.
Traffic is spread evenly across 24 hours when calculating average requests per second.
Peak traffic is estimated at 5 times the average traffic.
Every uploaded photo is stored for one year, with no deletion or compression assumed.

2. Calculate uploads per second, feed views per second (average and peak, using 5× for peak) and photo storage per year.

A. Daily Active Users (DAU)

Registered users = 10,000,000
Daily active users = 10% of registered users.
Daily Active Users = 10,000,000 × 0.10
Daily Active Users = 1,000,000 users

B. Photo Uploads Per Second

Each active user uploads one photo per day.
Daily uploads = 1,000,000 × 1
Daily uploads = 1,000,000 photos
Average uploads per second = 1,000,000 ÷ 86,400
Average uploads per second ≈ 11.6 or rounded off to 12
Peak uploads per second = 11.6 × 5
Peak uploads per second ≈ 58

C. Feed Views Per Second

Each active user views 50 feed pages per day.
Daily feed views = 1,000,000 × 50
Daily feed views = 50,000,000
Average feed views per second = 50,000,000 ÷ 86,400
Average feed views per second ≈ 579
Peak feed views per second = 579 × 5
Peak feed views per second ≈ 2,894
Result: Approximately 579 feed views per second on average and 2,894 at peak.

D. Photo Storage Per Year

Each original photo uses 2 MB.
Original photo storage per day = 1,000,000 × 2 MB = 2,000,000 MB = 2 TB.
Each thumbnail uses 50 KB.
Thumbnail storage per day = 1,000,000 × 50 KB = 50 GB.
Total new storage per day = 2 TB + 50 GB = 2.05 TB.
Annual storage = 2.05 TB × 365
Annual storage = 748.25 TB.
Result: Approximately 748.25 TB of new photo and thumbnail storage per year.

3. Is SnapShare Read-Heavy or Write-Heavy?

SnapShare is a read-heavy system because users view 50 million feed pages daily but upload only 1 million photos daily. This means feed viewing happens much more frequently than photo uploading. The architecture should therefore prioritize fast feed delivery, caching, database read replicas, and a content delivery network (CDN).

4.  Explain why photos should not be stored inside the database, and where they should go instead.
    Photos should not be stored directly inside the database because they are large files that require a lot of storage space and can slow down database queries and backups. Instead, photos should be stored in object storage, such as Azure Blob Storage, Amazon S3, or Google Cloud Storage. The database should store only the photo's metadata, such as the photo ID, owner, caption, upload date, and the file's storage location.

5.  Draw the architecture in a text diagram.

           USERS
                           |
                           v
                    +--------------+
                    |     CDN      |
                    +--------------+
                     |            |
             Cached photos        | Cache miss / API request
                     |            v
                     |     +-----------------+
                     |     | Load Balancer   |
                     |     +-----------------+
                     |              |
                     |              v
                     |     +-----------------+
                     |     |  App Servers    |
                     |     +-----------------+
                     |       |      |      |
                     |       |      |      |
                     |       v      v      v
                     |   +-------+ +------+ +----------------+
                     |   | Cache | |Database| | Object Storage|
                     |   +-------+ +------+ +----------------+
                     |              |                  ^
                     |              v                  |
                     |       +-------------+           |
                     |       | Read Replica|           |
                     |       +-------------+           |
                     |                                  |
                     |                          Original photo
                     |                                  |
                     |                           +-------------+
                     |                           |    Queue    |
                     |                           +-------------+
                     |                                  |
                     |                                  v
                     |                           +-------------+
                     |                           | Thumbnail   |
                     |                           |   Worker    |
                     |                           +-------------+
                     |                                  |
                     |                                  v
                     +-------------------------- Object Storage
                                                (thumbnails)

6.  Components and the Problems They Solve

CDN: Delivers frequently accessed photos and thumbnails from locations closer to users, reducing latency and load on the application servers.
Load Balancer: Distributes incoming API requests across multiple application servers to prevent any single server from becoming overloaded.
App Servers: Handle user authentication, photo upload requests, feed generation, follow relationships, and other application logic.
Cache: Stores frequently accessed feed data, user information, and other reusable results in memory to reduce repeated database queries.
Database: Stores structured information such as users, photo metadata, captions, follow relationships, and feed-related records.
Read Replica: Handles read queries separately from the primary database, helping the system serve many feed requests without overloading the primary database.
Object Storage: Stores the original photo files and generated thumbnails durably without placing large image files directly in the database.
Queue: Holds thumbnail-generation jobs so photo uploads can complete without waiting for image processing.
Thumbnail Worker: Processes queued jobs asynchronously, generates smaller versions of uploaded photos, and saves the thumbnails to object storage.

7. Describe the upload flow step by step, including the thumbnail job.

-A user selects a photo and submits it through the SnapShare application.
-The app server authenticates the user and validates the upload request, including the file type and size.
-The application uploads the original photo to object storage, using a unique photo identifier.
-The application saves the photo metadata, such as the owner, object-storage key, caption, and upload time, in the primary database.
-The application publishes a thumbnail-generation job to the queue.
-The application returns a successful upload response to the user once the original photo and required metadata have been saved and the job has been queued.
-A thumbnail worker retrieves the job and downloads the original photo from object storage.
-The worker resizes the photo to create a thumbnail and uploads it to object storage.
-The worker updates the photo's processing status in the database.
-When other users view their feeds, the app servers retrieve feed metadata and photo references, using the cache and read replica where appropriate.
-The CDN delivers the original photos or thumbnails to users, reducing repeated requests to the application servers and object storage.

8. Describe at least two trade-offs.
   A. Trade-Off 1: Caching vs. Freshness

Caching feed data reduces database load and improves response times. However, cached information may become outdated when a user uploads a new photo or follows someone new. SnapShare must balance cache performance with timely updates and cache invalidation.

B. Trade-Off 2: Asynchronous Processing vs. Immediate Availability

Using a queue and background worker allows users to upload photos without waiting for thumbnail generation. However, thumbnails may not be available immediately, and failed jobs require retries and monitoring.
