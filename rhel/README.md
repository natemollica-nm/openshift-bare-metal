## Creating RHEL Bootable USB Device on macOS

Prerequisites:

* Download ISO image: [RHEL Image Download](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/performing_a_standard_rhel_8_installation/downloading-beta-installation-images_installing-RHEL#downloading-a-specific-beta-iso-image_downloading-beta-installation-images)
* USB Flash Drive (8Gi)

Procedure:

1. Connect USB to macOS host.
2. From terminal run: `diskutil list`

    ```shell
    $ diskutil list
    /dev/disk0 (internal, physical):
       #:                       TYPE NAME                    SIZE       IDENTIFIER
       0:      GUID_partition_scheme                        *500.3 GB   disk0
       1:             Apple_APFS_ISC Container disk1         524.3 MB   disk0s1
       2:                 Apple_APFS Container disk3         494.4 GB   disk0s2
       3:        Apple_APFS_Recovery Container disk2         5.4 GB     disk0s3
    
    /dev/disk3 (synthesized):
       #:                       TYPE NAME                    SIZE       IDENTIFIER
       0:      APFS Container Scheme -                      +494.4 GB   disk3
                                     Physical Store disk0s2
       1:                APFS Volume Macintosh HD            10.2 GB    disk3s1
       2:              APFS Snapshot com.apple.os.update-... 10.2 GB    disk3s1s1
       3:                APFS Volume Preboot                 6.1 GB     disk3s2
       4:                APFS Volume Recovery                934.7 MB   disk3s3
       5:                APFS Volume Data                    379.3 GB   disk3s5
       6:                APFS Volume VM                      2.1 GB     disk3s6
    
    /dev/disk4 (external, physical):
       #:                       TYPE NAME                    SIZE       IDENTIFIER
       0:     FDisk_partition_scheme                        *61.5 GB    disk4
       1:             Windows_FAT_32 ESD-USB                 34.4 GB    disk4s1
                        (free space)                         27.1 GB    -
    ```

3. Determine **_device path_** from output.
   * Disk Path Format: `/dev/disknumber`
   * `disk0`: OS X recovery disk
   * `disk1`: OS X main disk
   * For this example output, `disk4` represents the external USB device.
4. Unmount the USB flash drive's filesystem volumes: `diskutil umountDisk /dev/disknumber`

    ```shell
    $ diskutil umountDisk /dev/disk4
    Unmount of all volumes on disk4 was successful
    ```

5. Use `dd` command to write ISO image to USB flash drive: `sudo dd if=/path/to/image.iso of=/dev/rdisknumber bs=1m status=progress`
    
    ```shell
    $ sudo dd if=rhel/rhel-9.4-x86_64-dvd.iso of=/dev/rdisk4 bs=1m status=progress
    ```
    > **_Note:_** macOS provides both a block (`/dev/disk*`) and character device (`/dev/rdisk*`) file for each storage
    > device. Writing an image to the `/dev/rdisknumber` character device is faster than writing to the
    > `/dev/disknumber` block device.
   
6. Wait for `dd` command to finish writing the image to the USB flash device as indicated by the return of the prompt cursor.