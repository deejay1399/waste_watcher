#!/bin/bash
flutter run --dart-define-from-file=config/firebase.json --dart-define-from-file=config/cloudinary.local.json "$@"
