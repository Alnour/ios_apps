---
name: contacts
description: "Contacts framework: CNContactPickerViewController (no permission needed), CNContact, labeled values, phone numbers"
metadata:
  languages: "swift"
  versions: "ios-26.5"
  revision: 1
  updated-on: "2026-10-01"
  source: community
  tags: "apple,ios,swift,contacts,contactsui,cncontact"
---

# Contacts / ContactsUI

## How our apps use it
- **Pick, don't read**: `CNContactPickerViewController` runs out-of-process and needs **no
  permission string**; the picked `CNContact` carries full data (name, org, emails, phones,
  thumbnail, `identifier`). Wrap in `UIViewControllerRepresentable`, implement
  `contactPicker(_:didSelect contact:)` and `contactPickerDidCancel`.
- Phone numbers come as `CNPhoneNumber` (`stringValue`); normalise to digits for `wa.me`/`sms:`.
- Only needed if the app wants to *re-sync* later: `CNContactStore` + `NSContactsUsageDescription`.

## Reference (developer.apple.com, fetched 2026-10-01)

### CNContactPickerViewController  
*iOS: 9.0.0 -* · <https://developer.apple.com/documentation/contactsui/cncontactpickerviewcontroller.md>


A view controller that displays an interface for picking contacts.

```
class CNContactPickerViewController
```

#### Overview

A [`CNContactPickerViewController`](/documentation/ContactsUI/CNContactPickerViewController) allows the user to select one or more
contacts (or their properties) from the list of contacts displayed in the contact
view controller ([`CNContactViewController`](/documentation/ContactsUI/CNContactViewController)). The picker supports both
single selection and multiselection of the contacts. The app using contact picker
view does not need access to the user’s contacts and the user will not be prompted
for “grant permission” access. The app has access only to the user’s final selection.

There are predefined predicates in this class that let you control the user selection
of the contact. Changing the predicates only take effect before the view is presented.

#### Topics

##### Displaying Contacts Properties

[`var displayedPropertyKeys: [String]?`](/documentation/ContactsUI/CNContactPickerViewController/displayedPropertyKeys)

The <doc://com.apple.documentation/documentation/Contacts/CNContact> property keys
to display in the contact detail card.

##### Responding to User Interactions

[`var delegate: (any CNContactPickerDelegate)?`](/documentation/ContactsUI/CNContactPickerViewController/delegate)

The delegate to be notified when the user selects a contact or a property.

[`protocol CNContactPickerDelegate`](/documentation/ContactsUI/CNContactPickerDelegate)

The methods that you implement to respond to contact-picker user events.

##### Predicates For Selecting Contacts

[`var predicateForEnablingContact: NSPredicate?`](/documentation/ContactsUI/CNContactPickerViewController/predicateForEnablingContact)

A predicate to determine the contact selectability in the list of contacts.

[`var predicateForSelectionOfContact: NSPredicate?`](/documentation/ContactsUI/CNContactPickerViewController/predicateForSelectionOfContact)

A predicate to control the return of the selected contact.

[`var predicateForSelectionOfProperty: NSPredicate?`](/documentation/ContactsUI/CNContactPickerViewController/predicateForSelectionOfProperty)

A predicate to control the properties of the selected contact.

#### Relationships

##### Conforms To

[`UIContentContainer`](/documentation/UIKit/UIContentContainer)

[`NSExtensionRequestHandling`](/documentation/Foundation/NSExtensionRequestHandling)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Equatable`](/documentation/Swift/Equatable)

[`UITraitChangeObservable-67e94`](/documentation/UIKit/UITraitChangeObservable-67e94)

[`NSCoding`](/documentation/Foundation/NSCoding)

[`UIActivityItemsConfigurationProviding`](/documentation/UIKit/UIActivityItemsConfigurationProviding)

[`UIFocusEnvironment`](/documentation/UIKit/UIFocusEnvironment)

[`Hashable`](/documentation/Swift/Hashable)

[`UITraitEnvironment`](/documentation/UIKit/UITraitEnvironment)

[`UIPasteConfigurationSupporting`](/documentation/UIKit/UIPasteConfigurationSupporting)

[`UIUserActivityRestoring`](/documentation/UIKit/UIUserActivityRestoring)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`UIStateRestoring`](/documentation/UIKit/UIStateRestoring)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`UIAppearanceContainer`](/documentation/UIKit/UIAppearanceContainer)

[`UIResponderStandardEditActions`](/documentation/UIKit/UIResponderStandardEditActions)

[`NSTouchBarProvider`](/documentation/AppKit/NSTouchBarProvider)

[`CVarArg`](/documentation/Swift/CVarArg)

##### Inherits From

[`UIViewController`](/documentation/UIKit/UIViewController)

### CNContact  
*iOS: 9.0.0 -* · <https://developer.apple.com/documentation/contacts/cncontact.md>


An immutable object that stores information about a single contact, such as the contact’s first name, phone numbers, and addresses.

```
class CNContact
```

#### Overview

A `CNContact` object stores an immutable copy of a contact’s information, so you cannot change the information in this object directly. Contact objects are thread-safe, so you may access them from any thread of your app.

To modify a contact’s information, call the <doc://com.apple.documentation/documentation/ObjectiveC/NSObject-swift.class/mutableCopy()> method to obtain a [`CNMutableContact`](/documentation/Contacts/CNMutableContact) object with the same information. After modifying the mutable contact, save your changes back to the contacts database using the [`CNContactStore`](/documentation/Contacts/CNContactStore) object.

Every contact in the contacts database has a unique ID, which you access using the [`identifier`](/documentation/Contacts/CNContact/identifier) property. The mutable and immutable versions of the same contact have the same identifier.

#### Topics

##### Identifying the Contact

[`var identifier: String`](/documentation/Contacts/CNContact/identifier)

A value that uniquely identifies a contact on the device.

[`var contactType: CNContactType`](/documentation/Contacts/CNContact/contactType)

An enum identifying the contact type.

[`enum CNContactType`](/documentation/Contacts/CNContactType)

The types a contact can be.

##### Getting Name Information

[`var namePrefix: String`](/documentation/Contacts/CNContact/namePrefix)

The name prefix of the contact.

[`var givenName: String`](/documentation/Contacts/CNContact/givenName)

The given name of the contact.

[`var middleName: String`](/documentation/Contacts/CNContact/middleName)

The middle name of the contact.

[`var familyName: String`](/documentation/Contacts/CNContact/familyName)

The family name of the contact.

[`var previousFamilyName: String`](/documentation/Contacts/CNContact/previousFamilyName)

A string for the previous family name of the contact.

[`var nameSuffix: String`](/documentation/Contacts/CNContact/nameSuffix)

The name suffix of the contact.

[`var nickname: String`](/documentation/Contacts/CNContact/nickname)

The nickname of the contact.

[`var phoneticGivenName: String`](/documentation/Contacts/CNContact/phoneticGivenName)

The phonetic given name of the contact.

[`var phoneticMiddleName: String`](/documentation/Contacts/CNContact/phoneticMiddleName)

The phonetic middle name of the contact.

[`var phoneticFamilyName: String`](/documentation/Contacts/CNContact/phoneticFamilyName)

A string for the phonetic family name of the contact.

##### Getting Work Information

[`var jobTitle: String`](/documentation/Contacts/CNContact/jobTitle)

The contact’s job title.

[`var departmentName: String`](/documentation/Contacts/CNContact/departmentName)

The name of the department associated with the contact.

[`var organizationName: String`](/documentation/Contacts/CNContact/organizationName)

The name of the organization associated with the contact.

[`var phoneticOrganizationName: String`](/documentation/Contacts/CNContact/phoneticOrganizationName)

The phonetic name of the organization associated with the contact.

##### Getting Addresses

[`var postalAddresses: [CNLabeledValue<CNPostalAddress>]`](/documentation/Contacts/CNContact/postalAddresses)

An array of labeled postal addresses for a contact.

[`var emailAddresses: [CNLabeledValue<NSString>]`](/documentation/Contacts/CNContact/emailAddresses)

An array of labeled email addresses for the contact.

[`var urlAddresses: [CNLabeledValue<NSString>]`](/documentation/Contacts/CNContact/urlAddresses)

An array of labeled URL addresses for a contact.

##### Getting Phone Information

[`var phoneNumbers: [CNLabeledValue<CNPhoneNumber>]`](/documentation/Contacts/CNContact/phoneNumbers)

An array of labeled phone numbers for a contact.

##### Getting Social Profiles

[`var socialProfiles: [CNLabeledValue<CNSocialProfile>]`](/documentation/Contacts/CNContact/socialProfiles)

An array of labeled social profiles for a contact.

##### Getting Birthday Information

[`var birthday: DateComponents?`](/documentation/Contacts/CNContact/birthday)

A date component for the Gregorian birthday of the contact.

[`var nonGregorianBirthday: DateComponents?`](/documentation/Contacts/CNContact/nonGregorianBirthday)

A date component for the non-Gregorian birthday of the contact.

[`var dates: [CNLabeledValue<NSDateComponents>]`](/documentation/Contacts/CNContact/dates)

An array containing labeled Gregorian dates.

##### Getting Notes

[`var note: String`](/documentation/Contacts/CNContact/note)

A string containing notes for the contact.

##### Getting Contact Images

[`var imageData: Data?`](/documentation/Contacts/CNContact/imageData)

The profile picture of a contact.

[`var thumbnailImageData: Data?`](/documentation/Contacts/CNContact/thumbnailImageData)

The thumbnail version of the contact’s profile picture.

[`var imageDataAvailable: Bool`](/documentation/Contacts/CNContact/imageDataAvailable)

A Boolean indicating whether a contact has a profile picture.

##### Getting Related Information

[`var contactRelations: [CNLabeledValue<CNContactRelation>]`](/documentation/Contacts/CNContact/contactRelations)

An array of labeled relations for the contact.

[`var instantMessageAddresses: [CNLabeledValue<CNInstantMessageAddress>]`](/documentation/Contacts/CNContact/instantMessageAddresses)

An array of labeled IM addresses for the contact.

##### Localizing Contact Data

[`class func localizedString(forKey: String) -> String`](/documentation/Contacts/CNContact/localizedString(forKey:))

Returns a string containing the localized contact property name.

##### Comparing Contacts

[`class func descriptorForAllComparatorKeys() -> any CNKeyDescriptor`](/documentation/Contacts/CNContact/descriptorForAllComparatorKeys())

Fetches all the keys required for the contact sort comparator.

[`class func comparator(forNameSortOrder: CNContactSortOrder) -> Comparator`](/documentation/Contacts/CNContact/comparator(forNameSortOrder:))

Returns a comparator to sort contacts with the specified order.

[`func isUnifiedWithContact(withIdentifier: String) -> Bool`](/documentation/Contacts/CNContact/isUnifiedWithContact(withIdentifier:))

Returns a Boolean indicating whether the current contact is a unified contact and includes a contact with the specified identifier.

[`enum CNContactSortOrder`](/documentation/Contacts/CNContactSortOrder)

Indicates the sorting order for contacts.

##### Checking the Availability of Data

[`func isKeyAvailable(String) -> Bool`](/documentation/Contacts/CNContact/isKeyAvailable(_:))

Determines whether the contact property value for the specified key is fetched.

[`func areKeysAvailable([any CNKeyDescriptor]) -> Bool`](/documentation/Contacts/CNContact/areKeysAvailable(_:))

Determines whether all contact property values for the specified keys are fetched.

##### Getting Search Predicates

Predicates to match contacts. You can only use these predicates with [`class CNContactStore`](/documentation/Contacts/CNContactStore)

The object that fetches and saves contacts, groups, and containers from the user’s Contacts database. and [`class CNContactFetchRequest`](/documentation/Contacts/CNContactFetchRequest)

An object that defines the options to use when fetching contacts..

[`class func predicateForContacts(matchingName: String) -> NSPredicate`](/documentation/Contacts/CNContact/predicateForContacts(matchingName:))

Returns a predicate to find the contacts matching the specified name.

[`class func predicateForContacts(withIdentifiers: [String]) -> NSPredicate`](/documentation/Contacts/CNContact/predicateForContacts(withIdentifiers:))

Returns a predicate to find the contacts matching the specified identifiers.

[`class func predicateForContactsInGroup(withIdentifier: String) -> NSPredicate`](/documentation/Contacts/CNContact/predicateForContactsInGroup(withIdentifier:))

Returns a predicate to find the contacts that are members in the specified group.

[`class func predicateForContactsInContainer(withIdentifier: String) -> NSPredicate`](/documentation/Contacts/CNContact/predicateForContactsInContainer(withIdentifier:))

Returns a predicate to find the contacts in the specified container.

[`class func predicateForContacts(matching: CNPhoneNumber) -> NSPredicate`](/documentation/Contacts/CNContact/predicateForContacts(matching:))

Returns a predicate to find the contacts whose phone number matches the specified value.

[`class func predicateForContacts(matchingEmailAddress: String) -> NSPredicate`](/documentation/Contacts/CNContact/predicateForContacts(matchingEmailAddress:))

Returns a predicate to find the contacts whose email address matches the specified value.

##### Initializers

[`init?(coder: NSCoder)`](/documentation/Contacts/CNContact/init(coder:))

##### Instance Properties

[`var debugDescription: String`](/documentation/Contacts/CNContact/debugDescription)

[`var description: String`](/documentation/Contacts/CNContact/description)

[`var shortDebugDescription: String`](/documentation/Contacts/CNContact/shortDebugDescription)

#### Relationships

##### Conforms To

[`NSCopying`](/documentation/Foundation/NSCopying)

[`Hashable`](/documentation/Swift/Hashable)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`Escapable`](/documentation/Swift/Escapable)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Identifiable`](/documentation/Swift/Identifiable)

[`CVarArg`](/documentation/Swift/CVarArg)

[`Copyable`](/documentation/Swift/Copyable)

[`NSItemProviderReading`](/documentation/Foundation/NSItemProviderReading)

[`NSItemProviderWriting`](/documentation/Foundation/NSItemProviderWriting)

[`NSMutableCopying`](/documentation/Foundation/NSMutableCopying)

[`NSCoding`](/documentation/Foundation/NSCoding)

[`NSSecureCoding`](/documentation/Foundation/NSSecureCoding)

[`Equatable`](/documentation/Swift/Equatable)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

##### Inherits From

[`NSObject-swift.class`](/documentation/ObjectiveC/NSObject-swift.class)

##### Inherited By

[`CNMutableContact`](/documentation/Contacts/CNMutableContact)

### CNLabeledValue  
*iOS: 9.0.0 -* · <https://developer.apple.com/documentation/contacts/cnlabeledvalue.md>


An immutable object that combines a contact property value with a label that describes that property.

```
class CNLabeledValue<ValueType> where ValueType : NSCopying, ValueType : NSSecureCoding
```

#### Overview

Labels describe the context for a property. For example, the label for a phone number indicates whether it corresponds to the user’s home, work, or iPhone number.

`CNLabeledValue` objects are thread-safe, and you can access their properties from any thread of your app.

#### Topics

##### Creating a labeled value

[`init(label: String?, value: ValueType)`](/documentation/Contacts/CNLabeledValue/init(label:value:))

Returns a new labeled value identifier.

[`+ (instancetype) labeledValueWithLabel:(NSString *) label value:(ValueType) value;`](/documentation/Contacts/CNLabeledValue/labeledValueWithLabel:value:)

Returns a new labeled value identifier.

##### Getting the label and value

[`var label: String?`](/documentation/Contacts/CNLabeledValue/label)

The label for a contact property value.

[`var value: ValueType`](/documentation/Contacts/CNLabeledValue/value)

A contact property value.

##### Setting labels and values

[`func settingLabel(String?) -> Self`](/documentation/Contacts/CNLabeledValue/settingLabel(_:))

Returns a labeled value object with an existing value and identifier.

[`func settingLabel(String?, value: ValueType) -> Self`](/documentation/Contacts/CNLabeledValue/settingLabel(_:value:))

Returns a labeled value object with the specified label and value with the existing identifier.

[`func settingValue(ValueType) -> Self`](/documentation/Contacts/CNLabeledValue/settingValue(_:))

Returns a new value for an existing label and identifier.

##### Localizing the label and value

[`class func localizedString(forLabel: String) -> String`](/documentation/Contacts/CNLabeledValue/localizedString(forLabel:))

Returns a localized string for the specified label.

##### Getting the unique identifier

[`var identifier: String`](/documentation/Contacts/CNLabeledValue/identifier)

A unique identifier for the labeled value object.

##### Getting common labels

[`let CNLabelHome: String`](/documentation/Contacts/CNLabelHome)

The label for identifying home information.

[`let CNLabelWork: String`](/documentation/Contacts/CNLabelWork)

The label for identifying work information.

[`let CNLabelSchool: String`](/documentation/Contacts/CNLabelSchool)

The label for the contact’s school.

[`let CNLabelOther: String`](/documentation/Contacts/CNLabelOther)

The label for identifying other information.

[`let CNLabelEmailiCloud: String`](/documentation/Contacts/CNLabelEmailiCloud)

The label for identifying the contact’s iCloud email information.

[`let CNLabelURLAddressHomePage: String`](/documentation/Contacts/CNLabelURLAddressHomePage)

The label for identifying URL information.

[`let CNLabelDateAnniversary: String`](/documentation/Contacts/CNLabelDateAnniversary)

The label for identifying the contact’s anniversary date.

##### Getting phone number labels

[`let CNLabelPhoneNumberMain: String`](/documentation/Contacts/CNLabelPhoneNumberMain)

The label for identifying the contact’s main phone number.

[`let CNLabelPhoneNumberiPhone: String`](/documentation/Contacts/CNLabelPhoneNumberiPhone)

The label for identifying the contact’s iPhone number.

[`let CNLabelPhoneNumberAppleWatch: String`](/documentation/Contacts/CNLabelPhoneNumberAppleWatch)

The label for identifying the contact’s Apple Watch phone number.

[`let CNLabelPhoneNumberMobile: String`](/documentation/Contacts/CNLabelPhoneNumberMobile)

The label for identifying the contact’s mobile phone number.

[`let CNLabelPhoneNumberPager: String`](/documentation/Contacts/CNLabelPhoneNumberPager)

The label for identifying the contact’s pager number.

[`let CNLabelPhoneNumberWorkFax: String`](/documentation/Contacts/CNLabelPhoneNumberWorkFax)

The label for identifying the contact’s work fax number.

[`let CNLabelPhoneNumberHomeFax: String`](/documentation/Contacts/CNLabelPhoneNumberHomeFax)

The label for identifying the contact’s home fax number.

[`let CNLabelPhoneNumberOtherFax: String`](/documentation/Contacts/CNLabelPhoneNumberOtherFax)

The label for identifying another fax number.

##### Getting immediate family relationship labels

[`let CNLabelContactRelationBrother: String`](/documentation/Contacts/CNLabelContactRelationBrother)

The label for the contact’s brother.

[`let CNLabelContactRelationChild: String`](/documentation/Contacts/CNLabelContactRelationChild)

The label for the contact’s child.

[`let CNLabelContactRelationDaughter: String`](/documentation/Contacts/CNLabelContactRelationDaughter)

The label for the contact’s daughter.

[`let CNLabelContactRelationElderBrother: String`](/documentation/Contacts/CNLabelContactRelationElderBrother)

The label for the contact’s elder brother.

[`let CNLabelContactRelationElderSibling: String`](/documentation/Contacts/CNLabelContactRelationElderSibling)

The label for the contact’s elder sibling.

[`let CNLabelContactRelationElderSister: String`](/documentation/Contacts/CNLabelContactRelationElderSister)

The label for the contact’s elder sister.

[`let CNLabelContactRelationEldestBrother: String`](/documentation/Contacts/CNLabelContactRelationEldestBrother)

The label for the contact’s eldest brother.

[`let CNLabelContactRelationEldestSister: String`](/documentation/Contacts/CNLabelContactRelationEldestSister)

The label for the contact’s eldest sister.

[`let CNLabelContactRelationFather: String`](/documentation/Contacts/CNLabelContactRelationFather)

The label for the contact’s father.

[`let CNLabelContactRelationFemalePartner: String`](/documentation/Contacts/CNLabelContactRelationFemalePartner)

The label for the contact’s female partner.

[`let CNLabelContactRelationHusband: String`](/documentation/Contacts/CNLabelContactRelationHusband)

The label for the contact’s husband.

[`let CNLabelContactRelationMalePartner: String`](/documentation/Contacts/CNLabelContactRelationMalePartner)

The label for the contact’s male partner.

[`let CNLabelContactRelationMother: String`](/documentation/Contacts/CNLabelContactRelationMother)

The label for the contact’s mother.

[`let CNLabelContactRelationParent: String`](/documentation/Contacts/CNLabelContactRelationParent)

The label for the contact’s parent.

[`let CNLabelContactRelationPartner: String`](/documentation/Contacts/CNLabelContactRelationPartner)

The label for the contact’s partner.

[`let CNLabelContactRelationSibling: String`](/documentation/Contacts/CNLabelContactRelationSibling)

The label for the contact’s sibling.

[`let CNLabelContactRelationSister: String`](/documentation/Contacts/CNLabelContactRelationSister)

The label for the contact’s sister.

[`let CNLabelContactRelationSon: String`](/documentation/Contacts/CNLabelContactRelationSon)

The label for the contact’s son.

[`let CNLabelContactRelationSpouse: String`](/documentation/Contacts/CNLabelContactRelationSpouse)

The label for the contact’s spouse.

[`let CNLabelContactRelationStepbrother: String`](/documentation/Contacts/CNLabelContactRelationStepbrother)

The label for the contact’s stepbrother.

[`let CNLabelContactRelationStepchild: String`](/documentation/Contacts/CNLabelContactRelationStepchild)

The label for the contact’s stepchild.

[`let CNLabelContactRelationStepdaughter: String`](/documentation/Contacts/CNLabelContactRelationStepdaughter)

The label for the contact’s stepdaughter.

[`let CNLabelContactRelationStepfather: String`](/documentation/Contacts/CNLabelContactRelationStepfather)

The label for the contact’s stepfather.

[`let CNLabelContactRelationStepmother: String`](/documentation/Contacts/CNLabelContactRelationStepmother)

The label for the contact’s stepmother.

[`let CNLabelContactRelationStepparent: String`](/documentation/Contacts/CNLabelContactRelationStepparent)

The label for the contact’s stepparent.

[`let CNLabelContactRelationStepsister: String`](/documentation/Contacts/CNLabelContactRelationStepsister)

The label for the contact’s stepsister.

[`let CNLabelContactRelationStepson: String`](/documentation/Contacts/CNLabelContactRelationStepson)

The label for the contact’s stepson.

[`let CNLabelContactRelationWife: String`](/documentation/Contacts/CNLabelContactRelationWife)

The label for the contact’s wife.

[`let CNLabelContactRelationYoungerBrother: String`](/documentation/Contacts/CNLabelContactRelationYoungerBrother)

The label for the contact’s younger brother.

[`let CNLabelContactRelationYoungerSibling: String`](/documentation/Contacts/CNLabelContactRelationYoungerSibling)

The label for the contact’s younger sibling.

[`let CNLabelContactRelationYoungerSister: String`](/documentation/Contacts/CNLabelContactRelationYoungerSister)

The label for the contact’s younger sister.

[`let CNLabelContactRelationYoungestBrother: String`](/documentation/Contacts/CNLabelContactRelationYoungestBrother)

The label for the contact’s youngest brother.

[`let CNLabelContactRelationYoungestSister: String`](/documentation/Contacts/CNLabelContactRelationYoungestSister)

The label for the contact’s youngest sister.

##### Getting acquaintance relationship labels

[`let CNLabelContactRelationBoyfriend: String`](/documentation/Contacts/CNLabelContactRelationBoyfriend)

The label for the contact’s boyfriend.

[`let CNLabelContactRelationColleague: String`](/documentation/Contacts/CNLabelContactRelationColleague)

The label for the contact’s colleague.

[`let CNLabelContactRelationFemaleFriend: String`](/documentation/Contacts/CNLabelContactRelationFemaleFriend)

The label for the contact’s female friend.

[`let CNLabelContactRelationFriend: String`](/documentation/Contacts/CNLabelContactRelationFriend)

The label for the contact’s friend.

[`let CNLabelContactRelationGirlfriend: String`](/documentation/Contacts/CNLabelContactRelationGirlfriend)

The label for the contact’s girlfriend.

[`let CNLabelContactRelationGirlfriendOrBoyfriend: String`](/documentation/Contacts/CNLabelContactRelationGirlfriendOrBoyfriend)

The label for the contact’s girlfriend or boyfriend.

[`let CNLabelContactRelationMaleFriend: String`](/documentation/Contacts/CNLabelContactRelationMaleFriend)

The label for the contact’s male friend.

##### Getting business relationship labels

[`let CNLabelContactRelationAssistant: String`](/documentation/Contacts/CNLabelContactRelationAssistant)

The label for the contact’s assistant.

[`let CNLabelContactRelationManager: String`](/documentation/Contacts/CNLabelContactRelationManager)

The label for the contact’s manager.

##### Getting education relationship labels

[`let CNLabelContactRelationTeacher: String`](/documentation/Contacts/CNLabelContactRelationTeacher)

The label for the contact’s teacher.

##### Getting in-law relationship labels

[`let CNLabelContactRelationBrotherInLaw: String`](/documentation/Contacts/CNLabelContactRelationBrotherInLaw)

The label for the contact’s brother-in-law.

[`let CNLabelContactRelationBrotherInLawElderSistersHusband: String`](/documentation/Contacts/CNLabelContactRelationBrotherInLawElderSistersHusband)

The label for the contact’s elder sister’s husband.

[`let CNLabelContactRelationBrotherInLawHusbandsBrother: String`](/documentation/Contacts/CNLabelContactRelationBrotherInLawHusbandsBrother)

The label for the contact’s husband’s brother.

[`let CNLabelContactRelationBrotherInLawHusbandsSistersHusband: String`](/documentation/Contacts/CNLabelContactRelationBrotherInLawHusbandsSistersHusband)

The label for the contact’s husband’s sister’s husband.

[`let CNLabelContactRelationBrotherInLawSistersHusband: String`](/documentation/Contacts/CNLabelContactRelationBrotherInLawSistersHusband)

The label for the contact’s sister’s husband.

[`let CNLabelContactRelationBrotherInLawSpousesBrother: String`](/documentation/Contacts/CNLabelContactRelationBrotherInLawSpousesBrother)

The label for the contact’s spouse’s brother.

[`let CNLabelContactRelationBrotherInLawWifesBrother: String`](/documentation/Contacts/CNLabelContactRelationBrotherInLawWifesBrother)

The label for the contact’s wife’s brother.

[`let CNLabelContactRelationBrotherInLawWifesSistersHusband: String`](/documentation/Contacts/CNLabelContactRelationBrotherInLawWifesSistersHusband)

The label for the contact’s wife’s sister’s husband.

[`let CNLabelContactRelationBrotherInLawYoungerSistersHusband: String`](/documentation/Contacts/CNLabelContactRelationBrotherInLawYoungerSistersHusband)

The label for the contact’s younger sister’s husband.

[`let CNLabelContactRelationChildInLaw: String`](/documentation/Contacts/CNLabelContactRelationChildInLaw)

The label for the contact’s child-in-law.

[`let CNLabelContactRelationCoBrotherInLaw: String`](/documentation/Contacts/CNLabelContactRelationCoBrotherInLaw)

The label for the contact’s co-brother-in-law.

[`let CNLabelContactRelationCoFatherInLaw: String`](/documentation/Contacts/CNLabelContactRelationCoFatherInLaw)

The label for the contact’s co-father-in-law.

[`let CNLabelContactRelationCoMotherInLaw: String`](/documentation/Contacts/CNLabelContactRelationCoMotherInLaw)

The label for the contact’s co-mother-in-law.

[`let CNLabelContactRelationCoParentInLaw: String`](/documentation/Contacts/CNLabelContactRelationCoParentInLaw)

The label for the contact’s co-parent-in-law.

[`let CNLabelContactRelationCoSiblingInLaw: String`](/documentation/Contacts/CNLabelContactRelationCoSiblingInLaw)

The label for the contact’s co-sibling-in-law.

[`let CNLabelContactRelationCoSisterInLaw: String`](/documentation/Contacts/CNLabelContactRelationCoSisterInLaw)

The label for the contact’s co-sister-in-law.

[`let CNLabelContactRelationElderBrotherInLaw: String`](/documentation/Contacts/CNLabelContactRelationElderBrotherInLaw)

The label for the contact’s elder brother-in-law.

[`let CNLabelContactRelationElderSiblingInLaw: String`](/documentation/Contacts/CNLabelContactRelationElderSiblingInLaw)

The label for the contact’s elder sibling-in-law.

[`let CNLabelContactRelationElderSisterInLaw: String`](/documentation/Contacts/CNLabelContactRelationElderSisterInLaw)

The label for the contact’s elder sister-in-law.

[`let CNLabelContactRelationFatherInLaw: String`](/documentation/Contacts/CNLabelContactRelationFatherInLaw)

The label for the contact’s father-in-law.

[`let CNLabelContactRelationFatherInLawHusbandsFather: String`](/documentation/Contacts/CNLabelContactRelationFatherInLawHusbandsFather)

The label for the contact’s husband’s father.

[`let CNLabelContactRelationFatherInLawOrStepfather: String`](/documentation/Contacts/CNLabelContactRelationFatherInLawOrStepfather)

The label for the contact’s father-in-law or stepfather.

[`let CNLabelContactRelationFatherInLawWifesFather: String`](/documentation/Contacts/CNLabelContactRelationFatherInLawWifesFather)

The label for the contact’s wife’s father.

[`let CNLabelContactRelationMotherInLaw: String`](/documentation/Contacts/CNLabelContactRelationMotherInLaw)

The label for the contact’s mother-in-law.

[`let CNLabelContactRelationMotherInLawHusbandsMother: String`](/documentation/Contacts/CNLabelContactRelationMotherInLawHusbandsMother)

The label for the contact’s husband’s mother.

[`let CNLabelContactRelationMotherInLawOrStepmother: String`](/documentation/Contacts/CNLabelContactRelationMotherInLawOrStepmother)

The label for the contact’s mother-in-law or stepmother.

[`let CNLabelContactRelationMotherInLawWifesMother: String`](/documentation/Contacts/CNLabelContactRelationMotherInLawWifesMother)

The label for the contact’s wife’s mother.

[`let CNLabelContactRelationParentInLaw: String`](/documentation/Contacts/CNLabelContactRelationParentInLaw)

The label for the contact’s parent-in-law.

[`let CNLabelContactRelationSiblingInLaw: String`](/documentation/Contacts/CNLabelContactRelationSiblingInLaw)

The label for the contact’s sibling-in-law.

[`let CNLabelContactRelationSisterInLaw: String`](/documentation/Contacts/CNLabelContactRelationSisterInLaw)

The label for the contact’s sister-in-law.

[`let CNLabelContactRelationSisterInLawBrothersWife: String`](/documentation/Contacts/CNLabelContactRelationSisterInLawBrothersWife)

The label for the contact’s brother’s wife.

[`let CNLabelContactRelationSisterInLawElderBrothersWife: String`](/documentation/Contacts/CNLabelContactRelationSisterInLawElderBrothersWife)

The label for the contact’s elder brother’s wife.

[`let CNLabelContactRelationSisterInLawHusbandsBrothersWife: String`](/documentation/Contacts/CNLabelContactRelationSisterInLawHusbandsBrothersWife)

The label for the contact’s husband’s brother’s wife.

[`let CNLabelContactRelationSisterInLawHusbandsSister: String`](/documentation/Contacts/CNLabelContactRelationSisterInLawHusbandsSister)

The label for the contact’s husband’s sister.

[`let CNLabelContactRelationSisterInLawSpousesSister: String`](/documentation/Contacts/CNLabelContactRelationSisterInLawSpousesSister)

The label for the contact’s spouse’s sister.

[`let CNLabelContactRelationSisterInLawWifesBrothersWife: String`](/documentation/Contacts/CNLabelContactRelationSisterInLawWifesBrothersWife)

The label for the contact’s wife’s brother’s wife.

[`let CNLabelContactRelationSisterInLawWifesSister: String`](/documentation/Contacts/CNLabelContactRelationSisterInLawWifesSister)

The label for the contact’s wife’s sister.

[`let CNLabelContactRelationSisterInLawYoungerBrothersWife: String`](/documentation/Contacts/CNLabelContactRelationSisterInLawYoungerBrothersWife)

The label for the contact’s younger brother’s wife.

[`let CNLabelContactRelationYoungerBrotherInLaw: String`](/documentation/Contacts/CNLabelContactRelationYoungerBrotherInLaw)

The label for the contact’s younger brother-in-law.

[`let CNLabelContactRelationYoungerSiblingInLaw: String`](/documentation/Contacts/CNLabelContactRelationYoungerSiblingInLaw)

The label for the contact’s younger sibling-in-law.

[`let CNLabelContactRelationYoungerSisterInLaw: String`](/documentation/Contacts/CNLabelContactRelationYoungerSisterInLaw)

The label for the contact’s younger sister-in-law.

##### Getting extended family relationship labels

[`let CNLabelContactRelationAunt: String`](/documentation/Contacts/CNLabelContactRelationAunt)

The label for the contact’s aunt.

[`let CNLabelContactRelationAuntFathersBrothersWife: String`](/documentation/Contacts/CNLabelContactRelationAuntFathersBrothersWife)

The label for the contact’s father’s brother’s wife.

[`let CNLabelContactRelationAuntFathersElderBrothersWife: String`](/documentation/Contacts/CNLabelContactRelationAuntFathersElderBrothersWife)

The label for the contact’s father’s elder brother’s wife.

[`let CNLabelContactRelationAuntFathersElderSister: String`](/documentation/Contacts/CNLabelContactRelationAuntFathersElderSister)

The label for the contact’s father’s elder sister.

[`let CNLabelContactRelationAuntFathersSister: String`](/documentation/Contacts/CNLabelContactRelationAuntFathersSister)

The label for the contact’s father’s sister.

[`let CNLabelContactRelationAuntFathersYoungerBrothersWife: String`](/documentation/Contacts/CNLabelContactRelationAuntFathersYoungerBrothersWife)

The label for the contact’s father’s younger brother’s wife.

[`let CNLabelContactRelationAuntFathersYoungerSister: String`](/documentation/Contacts/CNLabelContactRelationAuntFathersYoungerSister)

The label for the contact’s father’s younger sister.

[`let CNLabelContactRelationAuntMothersBrothersWife: String`](/documentation/Contacts/CNLabelContactRelationAuntMothersBrothersWife)

The label for the contact’s mother’s brother’s wife.

[`let CNLabelContactRelationAuntMothersElderSister: String`](/documentation/Contacts/CNLabelContactRelationAuntMothersElderSister)

The label for the contact’s mother’s elder sister.

[`let CNLabelContactRelationAuntMothersSister: String`](/documentation/Contacts/CNLabelContactRelationAuntMothersSister)

The label for the contact’s mother’s sister.

[`let CNLabelContactRelationAuntMothersYoungerSister: String`](/documentation/Contacts/CNLabelContactRelationAuntMothersYoungerSister)

The label for the contact’s mother’s younger sister.

[`let CNLabelContactRelationAuntParentsElderSister: String`](/documentation/Contacts/CNLabelContactRelationAuntParentsElderSister)

The label for the contact’s parent’s elder sister.

[`let CNLabelContactRelationAuntParentsSister: String`](/documentation/Contacts/CNLabelContactRelationAuntParentsSister)

The label for the contact’s parent’s sister.

[`let CNLabelContactRelationAuntParentsYoungerSister: String`](/documentation/Contacts/CNLabelContactRelationAuntParentsYoungerSister)

The label for the contact’s parent’s younger sister.

[`let CNLabelContactRelationCousin: String`](/documentation/Contacts/CNLabelContactRelationCousin)

The label for the contact’s cousin.

[`let CNLabelContactRelationCousinFathersBrothersDaughter: String`](/documentation/Contacts/CNLabelContactRelationCousinFathersBrothersDaughter)

The label for the contact’s father’s brother’s daughter.

[`let CNLabelContactRelationCousinFathersBrothersSon: String`](/documentation/Contacts/CNLabelContactRelationCousinFathersBrothersSon)

The label for the contact’s father’s brother’s son.

[`let CNLabelContactRelationCousinFathersSistersDaughter: String`](/documentation/Contacts/CNLabelContactRelationCousinFathersSistersDaughter)

The label for the contact’s father’s sister’s daughter.

[`let CNLabelContactRelationCousinFathersSistersSon: String`](/documentation/Contacts/CNLabelContactRelationCousinFathersSistersSon)

The label for the contact’s father’s sister’s son.

[`let CNLabelContactRelationCousinGrandparentsSiblingsChild: String`](/documentation/Contacts/CNLabelContactRelationCousinGrandparentsSiblingsChild)

The label for the contact’s grandparent’s sibling’s child.

[`let CNLabelContactRelationCousinGrandparentsSiblingsDaughter: String`](/documentation/Contacts/CNLabelContactRelationCousinGrandparentsSiblingsDaughter)

The label for the contact’s grandparent’s sibling’s daughter.

[`let CNLabelContactRelationCousinGrandparentsSiblingsSon: String`](/documentation/Contacts/CNLabelContactRelationCousinGrandparentsSiblingsSon)

The label for the contact’s grandparent’s sibling’s son.

[`let CNLabelContactRelationCousinMothersBrothersDaughter: String`](/documentation/Contacts/CNLabelContactRelationCousinMothersBrothersDaughter)

The label for the contact’s mother’s brother’s daughter.

[`let CNLabelContactRelationCousinMothersBrothersSon: String`](/documentation/Contacts/CNLabelContactRelationCousinMothersBrothersSon)

The label for the contact’s mother’s brother’s son.

[`let CNLabelContactRelationCousinMothersSistersDaughter: String`](/documentation/Contacts/CNLabelContactRelationCousinMothersSistersDaughter)

The label for the contact’s mother’s sister’s daughter.

[`let CNLabelContactRelationCousinMothersSistersSon: String`](/documentation/Contacts/CNLabelContactRelationCousinMothersSistersSon)

The label for the contact’s mother’s sister’s son.

[`let CNLabelContactRelationCousinOrSiblingsChild: String`](/documentation/Contacts/CNLabelContactRelationCousinOrSiblingsChild)

The label for the contact’s cousin’s or sibling’s child.

[`let CNLabelContactRelationCousinParentsSiblingsChild: String`](/documentation/Contacts/CNLabelContactRelationCousinParentsSiblingsChild)

The label for the contact’s parent’s sibling’s child.

[`let CNLabelContactRelationCousinParentsSiblingsDaughter: String`](/documentation/Contacts/CNLabelContactRelationCousinParentsSiblingsDaughter)

The label for the contact’s parent’s sibling’s daughter.

[`let CNLabelContactRelationCousinParentsSiblingsSon: String`](/documentation/Contacts/CNLabelContactRelationCousinParentsSiblingsSon)

The label for the contact’s parent’s sibling’s son.

[`let CNLabelContactRelationDaughterInLaw: String`](/documentation/Contacts/CNLabelContactRelationDaughterInLaw)

The label for the contact’s daughter-in-law.

[`let CNLabelContactRelationDaughterInLawOrSisterInLaw: String`](/documentation/Contacts/CNLabelContactRelationDaughterInLawOrSisterInLaw)

The label for the contact’s daughter-in-law or sister-in-law.

[`let CNLabelContactRelationDaughterInLawOrStepdaughter: String`](/documentation/Contacts/CNLabelContactRelationDaughterInLawOrStepdaughter)

The label for the contact’s daughter-in-law or stepdaughter.

[`let CNLabelContactRelationElderCousin: String`](/documentation/Contacts/CNLabelContactRelationElderCousin)

The label for the contact’s elder cousin.

[`let CNLabelContactRelationElderCousinFathersBrothersDaughter: String`](/documentation/Contacts/CNLabelContactRelationElderCousinFathersBrothersDaughter)

The label for the contact’s father’s brother’s daughter.

[`let CNLabelContactRelationElderCousinFathersBrothersSon: String`](/documentation/Contacts/CNLabelContactRelationElderCousinFathersBrothersSon)

The label for the contact’s father’s brother’s son.

[`let CNLabelContactRelationElderCousinFathersSistersDaughter: String`](/documentation/Contacts/CNLabelContactRelationElderCousinFathersSistersDaughter)

The label for the contact’s father’s sister’s daughter.

[`let CNLabelContactRelationElderCousinFathersSistersSon: String`](/documentation/Contacts/CNLabelContactRelationElderCousinFathersSistersSon)

The label for the contact’s father’s sister’s son.

[`let CNLabelContactRelationElderCousinMothersBrothersDaughter: String`](/documentation/Contacts/CNLabelContactRelationElderCousinMothersBrothersDaughter)

The label for the contact’s mother’s brother’s daughter.

[`let CNLabelContactRelationElderCousinMothersBrothersSon: String`](/documentation/Contacts/CNLabelContactRelationElderCousinMothersBrothersSon)

The label for the contact’s mother’s brother’s son.

[`let CNLabelContactRelationElderCousinMothersSiblingsDaughterOrFathersSistersDaughter: String`](/documentation/Contacts/CNLabelContactRelationElderCousinMothersSiblingsDaughterOrFathersSistersDaughter)

The label for the contact’s mother’s sibling’s daughter or father’s sister’s daughter.

[`let CNLabelContactRelationElderCousinMothersSiblingsSonOrFathersSistersSon: String`](/documentation/Contacts/CNLabelContactRelationElderCousinMothersSiblingsSonOrFathersSistersSon)

The label for the contact’s mother’s sibling’s son or father’s sister’s son.

[`let CNLabelContactRelationElderCousinMothersSistersDaughter: String`](/documentation/Contacts/CNLabelContactRelationElderCousinMothersSistersDaughter)

The label for the contact’s mother’s sister’s daughter.

[`let CNLabelContactRelationElderCousinMothersSistersSon: String`](/documentation/Contacts/CNLabelContactRelationElderCousinMothersSistersSon)

The label for the contact’s mother’s sister’s son.

[`let CNLabelContactRelationElderCousinParentsSiblingsDaughter: String`](/documentation/Contacts/CNLabelContactRelationElderCousinParentsSiblingsDaughter)

The label for the contact’s parent’s sibling’s daughter.

[`let CNLabelContactRelationElderCousinParentsSiblingsSon: String`](/documentation/Contacts/CNLabelContactRelationElderCousinParentsSiblingsSon)

The label for the contact’s parent’s sibling’s son.

[`let CNLabelContactRelationFemaleCousin: String`](/documentation/Contacts/CNLabelContactRelationFemaleCousin)

The label for the contact’s female cousin.

[`let CNLabelContactRelationGrandaunt: String`](/documentation/Contacts/CNLabelContactRelationGrandaunt)

The label for the contact’s grandaunt.

[`let CNLabelContactRelationGrandchild: String`](/documentation/Contacts/CNLabelContactRelationGrandchild)

The label for the contact’s grandchild.

[`let CNLabelContactRelationGrandchildOrSiblingsChild: String`](/documentation/Contacts/CNLabelContactRelationGrandchildOrSiblingsChild)

The label for the contact’s grandchild or sibling’s child.

[`let CNLabelContactRelationGranddaughter: String`](/documentation/Contacts/CNLabelContactRelationGranddaughter)

The label for the contact’s granddaughter.

[`let CNLabelContactRelationGranddaughterDaughtersDaughter: String`](/documentation/Contacts/CNLabelContactRelationGranddaughterDaughtersDaughter)

The label for the contact’s daughter’s daughter.

[`let CNLabelContactRelationGranddaughterSonsDaughter: String`](/documentation/Contacts/CNLabelContactRelationGranddaughterSonsDaughter)

The label for the contact’s son’s daughter.

[`let CNLabelContactRelationGranddaughterOrNiece: String`](/documentation/Contacts/CNLabelContactRelationGranddaughterOrNiece)

The label for the contact’s granddaughter or niece.

[`let CNLabelContactRelationGrandfather: String`](/documentation/Contacts/CNLabelContactRelationGrandfather)

The label for the contact’s grandfather.

[`let CNLabelContactRelationGrandfatherFathersFather: String`](/documentation/Contacts/CNLabelContactRelationGrandfatherFathersFather)

The label for the contact’s father’s father.

[`let CNLabelContactRelationGrandfatherMothersFather: String`](/documentation/Contacts/CNLabelContactRelationGrandfatherMothersFather)

The label for the contact’s mother’s father.

[`let CNLabelContactRelationGrandmother: String`](/documentation/Contacts/CNLabelContactRelationGrandmother)

The label for the contact’s grandmother.

[`let CNLabelContactRelationGrandmotherFathersMother: String`](/documentation/Contacts/CNLabelContactRelationGrandmotherFathersMother)

The label for the contact’s father’s mother.

[`let CNLabelContactRelationGrandmotherMothersMother: String`](/documentation/Contacts/CNLabelContactRelationGrandmotherMothersMother)

The label for the contact’s mother’s mother.

[`let CNLabelContactRelationGrandnephew: String`](/documentation/Contacts/CNLabelContactRelationGrandnephew)

The label for the contact’s grandnephew.

[`let CNLabelContactRelationGrandnephewBrothersGrandson: String`](/documentation/Contacts/CNLabelContactRelationGrandnephewBrothersGrandson)

The label for the contact’s brother’s grandson.

[`let CNLabelContactRelationGrandnephewSistersGrandson: String`](/documentation/Contacts/CNLabelContactRelationGrandnephewSistersGrandson)

The label for the contact’s sister’s grandson.

[`let CNLabelContactRelationGrandniece: String`](/documentation/Contacts/CNLabelContactRelationGrandniece)

The label for the contact’s grandniece.

[`let CNLabelContactRelationGrandnieceBrothersGranddaughter: String`](/documentation/Contacts/CNLabelContactRelationGrandnieceBrothersGranddaughter)

The label for the contact’s brother’s granddaughter.

[`let CNLabelContactRelationGrandnieceSistersGranddaughter: String`](/documentation/Contacts/CNLabelContactRelationGrandnieceSistersGranddaughter)

The label for the contact’s sister’s granddaughter.

[`let CNLabelContactRelationGrandparent: String`](/documentation/Contacts/CNLabelContactRelationGrandparent)

The label for the contact’s grandparent.

[`let CNLabelContactRelationGrandson: String`](/documentation/Contacts/CNLabelContactRelationGrandson)

The label for the contact’s grandson.

[`let CNLabelContactRelationGrandsonDaughtersSon: String`](/documentation/Contacts/CNLabelContactRelationGrandsonDaughtersSon)

The label for the contact’s daughter’s son.

[`let CNLabelContactRelationGrandsonSonsSon: String`](/documentation/Contacts/CNLabelContactRelationGrandsonSonsSon)

The label for the contact’s son’s son.

[`let CNLabelContactRelationGrandsonOrNephew: String`](/documentation/Contacts/CNLabelContactRelationGrandsonOrNephew)

The label for the contact’s grandson or nephew.

[`let CNLabelContactRelationGranduncle: String`](/documentation/Contacts/CNLabelContactRelationGranduncle)

The label for the contact’s granduncle.

[`let CNLabelContactRelationGreatGrandchild: String`](/documentation/Contacts/CNLabelContactRelationGreatGrandchild)

The label for the contact’s grandchild.

[`let CNLabelContactRelationGreatGrandchildOrSiblingsGrandchild: String`](/documentation/Contacts/CNLabelContactRelationGreatGrandchildOrSiblingsGrandchild)

The label for the contact’s grandchild or sibling’s grandchild.

[`let CNLabelContactRelationGreatGranddaughter: String`](/documentation/Contacts/CNLabelContactRelationGreatGranddaughter)

The label for the contact’s great-granddaughter.

[`let CNLabelContactRelationGreatGrandfather: String`](/documentation/Contacts/CNLabelContactRelationGreatGrandfather)

The label for the contact’s great-grandfather.

[`let CNLabelContactRelationGreatGrandmother: String`](/documentation/Contacts/CNLabelContactRelationGreatGrandmother)

The label for the contact’s great-grandmother.

[`let CNLabelContactRelationGreatGrandparent: String`](/documentation/Contacts/CNLabelContactRelationGreatGrandparent)

The label for the contact’s great-grandparent.

[`let CNLabelContactRelationGreatGrandson: String`](/documentation/Contacts/CNLabelContactRelationGreatGrandson)

The label for the contact’s great-grandson.

[`let CNLabelContactRelationMaleCousin: String`](/documentation/Contacts/CNLabelContactRelationMaleCousin)

The label for the contact’s male cousin.

[`let CNLabelContactRelationNephew: String`](/documentation/Contacts/CNLabelContactRelationNephew)

The label for the contact’s nephew.

[`let CNLabelContactRelationNephewBrothersSon: String`](/documentation/Contacts/CNLabelContactRelationNephewBrothersSon)

The label for the contact’s brother’s son.

[`let CNLabelContactRelationNephewBrothersSonOrHusbandsSiblingsSon: String`](/documentation/Contacts/CNLabelContactRelationNephewBrothersSonOrHusbandsSiblingsSon)

The label for the contact’s brother’s son or husband’s sibling’s son.

[`let CNLabelContactRelationNephewOrCousin: String`](/documentation/Contacts/CNLabelContactRelationNephewOrCousin)

The label for the contact’s nephew or cousin.

[`let CNLabelContactRelationNephewSistersSon: String`](/documentation/Contacts/CNLabelContactRelationNephewSistersSon)

The label for the contact’s sister’s son.

[`let CNLabelContactRelationNephewSistersSonOrWifesSiblingsSon: String`](/documentation/Contacts/CNLabelContactRelationNephewSistersSonOrWifesSiblingsSon)

The label for the contact’s sister’s son or wife’s sibling’s son.

[`let CNLabelContactRelationNiece: String`](/documentation/Contacts/CNLabelContactRelationNiece)

The label for the contact’s niece.

[`let CNLabelContactRelationNieceBrothersDaughter: String`](/documentation/Contacts/CNLabelContactRelationNieceBrothersDaughter)

The label for the contact’s brother’s daughter.

[`let CNLabelContactRelationNieceBrothersDaughterOrHusbandsSiblingsDaughter: String`](/documentation/Contacts/CNLabelContactRelationNieceBrothersDaughterOrHusbandsSiblingsDaughter)

The label for the contact’s brother’s daughter or husband’s sibling’s daughter.

[`let CNLabelContactRelationNieceOrCousin: String`](/documentation/Contacts/CNLabelContactRelationNieceOrCousin)

The label for the contact’s niece or cousin.

[`let CNLabelContactRelationNieceSistersDaughter: String`](/documentation/Contacts/CNLabelContactRelationNieceSistersDaughter)

The label for the contact’s sister’s daughter.

[`let CNLabelContactRelationNieceSistersDaughterOrWifesSiblingsDaughter: String`](/documentation/Contacts/CNLabelContactRelationNieceSistersDaughterOrWifesSiblingsDaughter)

The label for the contact’s sister’s daughter or wife’s sibling’s daughter.

[`let CNLabelContactRelationParentsElderSibling: String`](/documentation/Contacts/CNLabelContactRelationParentsElderSibling)

The label for the contact’s parent’s elder sibling.

[`let CNLabelContactRelationParentsSibling: String`](/documentation/Contacts/CNLabelContactRelationParentsSibling)

The label for the contact’s parent’s sibling.

[`let CNLabelContactRelationParentsSiblingFathersElderSibling: String`](/documentation/Contacts/CNLabelContactRelationParentsSiblingFathersElderSibling)

The label for the contact’s father’s elder sibling.

[`let CNLabelContactRelationParentsSiblingFathersSibling: String`](/documentation/Contacts/CNLabelContactRelationParentsSiblingFathersSibling)

The label for the contact’s father’s sibling.

[`let CNLabelContactRelationParentsSiblingFathersYoungerSibling: String`](/documentation/Contacts/CNLabelContactRelationParentsSiblingFathersYoungerSibling)

The label for the contact’s father’s youngest sibling.

[`let CNLabelContactRelationParentsSiblingMothersElderSibling: String`](/documentation/Contacts/CNLabelContactRelationParentsSiblingMothersElderSibling)

The label for the contact’s mother’s elder sibling.

[`let CNLabelContactRelationParentsSiblingMothersSibling: String`](/documentation/Contacts/CNLabelContactRelationParentsSiblingMothersSibling)

The label for the contact’s mother’s sibling.

[`let CNLabelContactRelationParentsSiblingMothersYoungerSibling: String`](/documentation/Contacts/CNLabelContactRelationParentsSiblingMothersYoungerSibling)

The label for the contact’s mother’s younger sibling.

[`let CNLabelContactRelationParentsYoungerSibling: String`](/documentation/Contacts/CNLabelContactRelationParentsYoungerSibling)

The label for the contact’s parent’s younger sibling.

[`let CNLabelContactRelationSiblingsChild: String`](/documentation/Contacts/CNLabelContactRelationSiblingsChild)

The label for the contact’s sibling’s child.

[`let CNLabelContactRelationSonInLaw: String`](/documentation/Contacts/CNLabelContactRelationSonInLaw)

The label for the contact’s son-in-law.

[`let CNLabelContactRelationSonInLawOrBrotherInLaw: String`](/documentation/Contacts/CNLabelContactRelationSonInLawOrBrotherInLaw)

The label for the contact’s son-in-law or brother-in-law.

[`let CNLabelContactRelationSonInLawOrStepson: String`](/documentation/Contacts/CNLabelContactRelationSonInLawOrStepson)

The label for the contact’s son-in-law or stepson.

[`let CNLabelContactRelationUncle: String`](/documentation/Contacts/CNLabelContactRelationUncle)

The label for the contact’s uncle.

[`let CNLabelContactRelationUncleFathersBrother: String`](/documentation/Contacts/CNLabelContactRelationUncleFathersBrother)

The label for the contact’s father’s brother.

[`let CNLabelContactRelationUncleFathersElderBrother: String`](/documentation/Contacts/CNLabelContactRelationUncleFathersElderBrother)

The label for the contact’s father’s elder brother.

[`let CNLabelContactRelationUncleFathersElderSistersHusband: String`](/documentation/Contacts/CNLabelContactRelationUncleFathersElderSistersHusband)

The label for the contact’s elder sister’s husband.

[`let CNLabelContactRelationUncleFathersSistersHusband: String`](/documentation/Contacts/CNLabelContactRelationUncleFathersSistersHusband)

The label for the contact’s father’s sister’s husband.

[`let CNLabelContactRelationUncleFathersYoungerBrother: String`](/documentation/Contacts/CNLabelContactRelationUncleFathersYoungerBrother)

The label for the contact’s father’s younger brother.

[`let CNLabelContactRelationUncleFathersYoungerSistersHusband: String`](/documentation/Contacts/CNLabelContactRelationUncleFathersYoungerSistersHusband)

The label for the contact’s father’s younger sister’s husband.

[`let CNLabelContactRelationUncleMothersBrother: String`](/documentation/Contacts/CNLabelContactRelationUncleMothersBrother)

The label for the contact’s mother’s brother.

[`let CNLabelContactRelationUncleMothersElderBrother: String`](/documentation/Contacts/CNLabelContactRelationUncleMothersElderBrother)

The label for the contact’s mother’s elder brother.

[`let CNLabelContactRelationUncleMothersSistersHusband: String`](/documentation/Contacts/CNLabelContactRelationUncleMothersSistersHusband)

The label for the contact’s mother’s sister’s husband.

[`let CNLabelContactRelationUncleMothersYoungerBrother: String`](/documentation/Contacts/CNLabelContactRelationUncleMothersYoungerBrother)

The label for the contact’s mother’s younger brother.

[`let CNLabelContactRelationUncleParentsBrother: String`](/documentation/Contacts/CNLabelContactRelationUncleParentsBrother)

The label for the contact’s parent’s brother.

[`let CNLabelContactRelationUncleParentsElderBrother: String`](/documentation/Contacts/CNLabelContactRelationUncleParentsElderBrother)

The label for the contact’s parent’s elder brother.

[`let CNLabelContactRelationUncleParentsYoungerBrother: String`](/documentation/Contacts/CNLabelContactRelationUncleParentsYoungerBrother)

The label for the contact’s parent’s younger brother.

[`let CNLabelContactRelationYoungerCousin: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousin)

The label for the contact’s younger cousin.

[`let CNLabelContactRelationYoungerCousinFathersBrothersDaughter: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinFathersBrothersDaughter)

The label for the contact’s father’s brother’s younger daughter.

[`let CNLabelContactRelationYoungerCousinFathersBrothersSon: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinFathersBrothersSon)

The label for the contact’s father’s brother’s younger son.

[`let CNLabelContactRelationYoungerCousinFathersSistersDaughter: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinFathersSistersDaughter)

The label for the contact’s father’s sister’s younger daughter.

[`let CNLabelContactRelationYoungerCousinFathersSistersSon: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinFathersSistersSon)

The label for the contact’s father’s sister’s younger son.

[`let CNLabelContactRelationYoungerCousinMothersBrothersDaughter: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinMothersBrothersDaughter)

The label for the contact’s mother’s brother’s younger daughter.

[`let CNLabelContactRelationYoungerCousinMothersBrothersSon: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinMothersBrothersSon)

The label for the contact’s mother’s brother’s younger son.

[`let CNLabelContactRelationYoungerCousinMothersSiblingsDaughterOrFathersSistersDaughter: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinMothersSiblingsDaughterOrFathersSistersDaughter)

The label for the contact’s mother’s sibling’s younger daughter or father’s sister’s younger daughter.

[`let CNLabelContactRelationYoungerCousinMothersSiblingsSonOrFathersSistersSon: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinMothersSiblingsSonOrFathersSistersSon)

The label for the contact’s mother’s sibling’s younger son or father’s sister’s younger son.

[`let CNLabelContactRelationYoungerCousinMothersSistersDaughter: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinMothersSistersDaughter)

The label for the contact’s mother’s sister’s younger daughter.

[`let CNLabelContactRelationYoungerCousinMothersSistersSon: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinMothersSistersSon)

The label for the contact’s mother’s sister’s younger son.

[`let CNLabelContactRelationYoungerCousinParentsSiblingsDaughter: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinParentsSiblingsDaughter)

The label for the contact’s parent’s sibling’s younger daughter.

[`let CNLabelContactRelationYoungerCousinParentsSiblingsSon: String`](/documentation/Contacts/CNLabelContactRelationYoungerCousinParentsSiblingsSon)

The label for the contact’s parent’s sibling’s younger son.

##### Initializers

[`init?(coder: NSCoder)`](/documentation/Contacts/CNLabeledValue/init(coder:))

#### Relationships

##### Conforms To

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

[`CVarArg`](/documentation/Swift/CVarArg)

[`Equatable`](/documentation/Swift/Equatable)

[`NSCopying`](/documentation/Foundation/NSCopying)

[`NSCoding`](/documentation/Foundation/NSCoding)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`Hashable`](/documentation/Swift/Hashable)

[`NSSecureCoding`](/documentation/Foundation/NSSecureCoding)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

##### Inherits From

[`NSObject-swift.class`](/documentation/ObjectiveC/NSObject-swift.class)

### CNPhoneNumber  
*iOS: 9.0.0 -* · <https://developer.apple.com/documentation/contacts/cnphonenumber.md>


An immutable object representing a phone number for a contact.

```
class CNPhoneNumber
```

#### Overview

`CNPhoneNumber` objects are thread-safe, and you may access their properties from any thread of your app.

#### Topics

##### Creating a Phone Number Object

[`init(stringValue: String)`](/documentation/Contacts/CNPhoneNumber/init(stringValue:))

Returns a new phone number object initialized with the specified phone number string.

[`+ (instancetype) phoneNumberWithStringValue:(NSString *) stringValue;`](/documentation/Contacts/CNPhoneNumber/phoneNumberWithStringValue:)

Returns a new phone number object initialized with the specified phone number string.

##### Getting the Phone Number

[`var stringValue: String`](/documentation/Contacts/CNPhoneNumber/stringValue)

The string value of the phone number.

##### Getting Phone-Related Keys

[`let CNContactPhoneNumbersKey: String`](/documentation/Contacts/CNContactPhoneNumbersKey)

A phone numbers of a contact.

##### Deprecated

[`init!()`](/documentation/Contacts/CNPhoneNumber/init())

[`class func new() -> Self!`](/documentation/Contacts/CNPhoneNumber/new())

##### Initializers

[`init?(coder: NSCoder)`](/documentation/Contacts/CNPhoneNumber/init(coder:))

#### Relationships

##### Conforms To

[`CVarArg`](/documentation/Swift/CVarArg)

[`NSCopying`](/documentation/Foundation/NSCopying)

[`CustomStringConvertible`](/documentation/Swift/CustomStringConvertible)

[`NSSecureCoding`](/documentation/Foundation/NSSecureCoding)

[`Hashable`](/documentation/Swift/Hashable)

[`NSCoding`](/documentation/Foundation/NSCoding)

[`Equatable`](/documentation/Swift/Equatable)

[`CustomDebugStringConvertible`](/documentation/Swift/CustomDebugStringConvertible)

[`NSObjectProtocol`](/documentation/ObjectiveC/NSObjectProtocol)

##### Inherits From

[`NSObject-swift.class`](/documentation/ObjectiveC/NSObject-swift.class)
