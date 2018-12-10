import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final String imageUrl;

  ImageInput(this.setImage, [this.imageUrl]);

  @override
  State<StatefulWidget> createState() {
    return _ImageInputState();
  }
}

class _ImageInputState extends State<ImageInput> {
  File _imageFile;

  Future _getImage(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop();
    final File file = await ImagePicker.pickImage(
      source: source,
      maxWidth: 480.0,
      maxHeight: 480.0,
    );
    setState(() {
      _imageFile = file;
    });
    widget.setImage(file);
  }

  void _addPhoto(BuildContext context) {
    final buttonColor = Colors.white;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 160.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an Image',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                RaisedButton(
                  onPressed: () => _getImage(context, ImageSource.camera),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.photo_camera, color: buttonColor),
                      SizedBox(width: 6.0),
                      Text(
                        'From Camera',
                        style: TextStyle(color: buttonColor),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                RaisedButton(
                  onPressed: () => _getImage(context, ImageSource.gallery),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.photo_library, color: buttonColor),
                      SizedBox(width: 6.0),
                      Text(
                        'From Gallery',
                        style: TextStyle(color: buttonColor),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).primaryColor;
    Widget previewImage = Text('Please pick an image.');
    if (_imageFile != null) {
      previewImage = Image.file(
        _imageFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300.0,
      );
    } else if (widget.imageUrl != null) {
      previewImage = Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 300.0,
      );
    }
    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(
            color: buttonColor,
            width: 2.0,
          ),
          onPressed: () => _addPhoto(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.image, color: buttonColor),
              SizedBox(width: 6.0),
              Text(
                '${_imageFile == null && widget.imageUrl == null ? 'Add' : 'Update'} an image',
                style: TextStyle(color: buttonColor),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.0),
        previewImage,
      ],
    );
  }
}
