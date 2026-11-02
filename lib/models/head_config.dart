import '../utils/enums.dart';

class HeadConfig{
  final int eyes;
  final int nose;
  final int mouth;
  final int hair;


const HeadConfig({
  this.eyes = 0,
  this.nose = 0,
  this.mouth = 0,
  this.hair = 0 
});

HeadConfig copyWith({int? eyes, int? nose, int? mouth, int? hair}){
  return HeadConfig(
    eyes: eyes ?? this.eyes,
    nose: nose ?? this.nose,
    mouth: mouth ?? this.mouth,
    hair: hair ?? this.hair,
  );
}

int optionFor(HeadPart part){
  return switch(part){
    HeadPart.eyes => eyes,
    HeadPart.nose => nose,
    HeadPart.mouth => mouth,
    HeadPart.hair => hair,
  };
}

HeadConfig withOption(HeadPart part, int option){
  return switch(part){
    HeadPart.eyes => copyWith(eyes: option),
    HeadPart.nose => copyWith(nose: option),
    HeadPart.mouth => copyWith(mouth: option),
    HeadPart.hair => copyWith(hair: option),
  };
}
}