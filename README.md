# Azure Resource Manager QuickStart Templates
[![Travis](https://img.shields.io/travis/Azure/azure-quickstart-templates/master.svg?label=travis&style=flat-square)](https://travis-ci.org/Azure/azure-quickstart-templates)

This repo contains all currently available Azure Resource Manager templates contributed by the community. A searchable template index is maintained at https://azure.microsoft.com/en-us/documentation/templates/.

See the [**Contribution guide**](/1-CONTRIBUTION-GUIDE/README.md#contribution-guide) for how to use or contribute to this repo.

## NOTE
A draft of the new [**best practices document**](/1-CONTRIBUTION-GUIDE/best-practices.md) has been merged.

# Upcoming Changes
We are going to be making a few changes in the structure and practices of this repo over the next few months, including (but not limited to :wink:) the following:
- Restructure the samples into sub folders to remove the noise from the root (if you made it this far you know what I mean) and provide some clarity about the samples in the repo
- Include samples for QuickStarts as well as Azure Applications (managed and unmanaged)
- Provide samples for Azure Policy
- Merging best practices with the Azure marketplace (there are some contradictory practices in place today)
- Provide static analysis automation of templates (contributions welcome [here](/test/README.md))
- Updating documentation to reflect these changes

## Why is this important?
If you contribute to the repo, some practices will be changing and it will be important to follow the readme since many of the samples will be grandfathered into the old practices.  Also, if you consume the repo thorugh the API the structure will be changing.  Today many callers assume a folder contains a sample, after the restructuring the metadata.json file will be the key to finding samples.  This is actually true today if you want to start updating your code.

## When?
We want to give everyone notice of the changes so they will be slowly rolled out over the next few months.  We'll post more detailed dates once we have them.


### Final Note
This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

# আজুর রিসোর্স ম্যানেজার কুইক স্টার্ট টেমপ্লেট
[! [ট্রাভিস]  [GITHUB]  (https://img.shields.io/travis/Azure/azure-quickstart-templates/master.svg?label=travis&style=flat-square)]  [GITHUB] (https://travis-ci.org/ আকাশী নীল / আকাশী নীল-দ্রুতশুরু-টেমপ্লেট)

এই রেপো সম্প্রদায় দ্বারা অবদান সমস্ত বর্তমানে উপলব্ধ Azure রিসোর্স ম্যানেজার টেমপ্লেট রয়েছে। একটি অনুসন্ধানযোগ্য টেমপ্লেট সূচী  [GITHUB] ( https://azure.microsoft.com/en-us/documentation/templates) এ রক্ষণাবেক্ষণ করা হয়।

এই রেপোতে কীভাবে অবদান বা অবদান রাখতে হবে তার জন্য [** অবদান গাইড **] (/ 1-অনুদান-নির্দেশিকা / README.md # অবদান-নির্দেশিকা) দেখুন।

## বিঃদ্রঃ
নতুন [** সর্বোত্তম অনুশীলনের নথি **] (/ 1-সহযোগী-নির্দেশিকা / সর্বোত্তম-অনুশীলনগুলি.এমডি) খসড়াটি একত্রিত করা হয়েছে।

# আসন্ন পরিবর্তন
আমরা পরবর্তী কয়েক মাসে এই রেপোটির গঠন ও অনুশীলনগুলিতে কয়েকটি পরিবর্তন করতে যাচ্ছি, এতে অন্তর্ভুক্ত রয়েছে (তবে সীমাবদ্ধ নয়: wink :) নিম্নলিখিতটি:
- রুট থেকে শব্দটি সরিয়ে ফেলতে সাব ফোল্ডারগুলিতে নমুনাগুলিকে পুনর্নির্মাণ করুন (যদি আপনি এই পর্যন্ত আপনি এটি বোঝেন যে আমি কী বুঝাতে চাইছি) এবং রেপোতে নমুনার বিষয়ে কিছু স্বচ্ছতা প্রদান করুন
- QuickStarts পাশাপাশি Azure অ্যাপ্লিকেশন জন্য নমুনা অন্তর্ভুক্ত (পরিচালিত এবং unmanaged)
- Azure নীতি জন্য নমুনা প্রদান
- Azure বাজারের সাথে সর্বোত্তম অনুশীলনগুলি মার্জ করা (আজকের স্থানে কিছু দ্বন্দ্বমূলক অনুশীলন আছে)
- টেমপ্লেট স্ট্যাটিক বিশ্লেষণ অটোমেশন প্রদান (অবদান স্বাগত [এখানে] (/ পরীক্ষা / README.md))
- এই পরিবর্তন প্রতিফলিত করার জন্য ডকুমেন্টেশন আপডেট করা হচ্ছে

## এটা জরুরী কেন?
আপনি যদি রেপোতে অবদান রাখেন, তবে কিছু অনুশীলনগুলি পরিবর্তিত হবে এবং পাঠ্যক্রমটি অনুসরণ করা গুরুত্বপূর্ণ হবে কারণ অনেকগুলি নমুনা পুরাতন অনুশীলনগুলিতে দাদা হবে। এছাড়াও, যদি আপনি রিপো থোরাজটি ব্যবহার করেন তবে এপিআইটি পরিবর্তন হয়ে যাবে। আজ অনেক কলার মনে করে যে একটি ফোল্ডারে একটি নমুনা থাকে, পুনর্গঠনের পরে metadata.json ফাইলটি নমুনা খুঁজে পেতে চাবি হবে। আপনি যদি আপনার কোড আপডেট করা শুরু করতে চান তাহলে এটি আসলেই সত্য।

## কখন?
আমরা প্রত্যেককে পরিবর্তনগুলির বিজ্ঞপ্তি দিতে চাই যাতে পরবর্তী ধাপে তারা ধীরে ধীরে ফুটে উঠবে। আমরা তাদের আছে একবার আমরা আরো বিস্তারিত তারিখ পোস্ট করব।


### চূড়ান্ত নোট
এই প্রকল্পটি [মাইক্রোসফ্ট ওপেন সোর্স কোড অফ আচার] [GITHUB] (https://opensource.microsoft.com/codeofconduct/) গ্রহণ করেছে। আরও তথ্যের জন্য দেখুন [আচরণবিধি প্রশ্নাবলী কোড] [github](https://opensource.microsoft.com/codeofconduct/faq/) অথবা কোনও অতিরিক্ত প্রশ্নগুলির সাথে [opencode@microsoft.com] (mailto: opencode@microsoft.com) যোগাযোগ করুন অথবা মন্তব্য নেই।
