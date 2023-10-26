package org.ramith.qrcodegenerator.controllers;


import net.glxn.qrgen.javase.QRCode;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;

@RestController
public class QRCodeGeneratorRestController {


    Logger logger = LoggerFactory.getLogger(QRCodeGeneratorRestController.class);


    /**
     * Generate QR code for the given content
     * @param content - content to be encoded in the QR code
     * @return - QR code image
     * @throws Exception - throws exception if any
     */
    @GetMapping(value = "/qrcode", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<BufferedImage> qrcode(@RequestParam(name = "content", required = true) String content)
            throws Exception {
        logger.info("Generating QR code for the content: {}", content);
        return ResponseEntity.ok(generateQRCodeImage(content));
    }
    public static BufferedImage generateQRCodeImage(String barcodeText) throws Exception {
        ByteArrayOutputStream stream = QRCode
                .from(barcodeText)
                .withSize(250, 250)
                .stream();
        ByteArrayInputStream bis = new ByteArrayInputStream(stream.toByteArray());

        return ImageIO.read(bis);
    }
}
