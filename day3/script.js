let notes = [
    { id: 1, text: "Buy milk and bread", category: "personal" },
    { id: 2, text: "Finish the Day 3 assignment", category: "study" },
    { id: 3, text: "Email the project report to Grace", category: "work" },
    { id: 4, text: "Revise Javascript arrays", category: "study" },
    { id: 5, text: "call mum", category: "personal" },
];

function searchNotes(word) {
    return notes.filter(note =>
        note.text.toLowerCase().includes(word.toLowerCase));
}


function longestNote() {
  if (notes.length === 0) {
    return null;
  }

  return notes.reduce((longest, note) => {
    if (note.text.length > longest.text.length) {
      return note;
    }

    return longest;
  });
}

function countByCategory() {
  let counts = {
    personal: 0,
    work: 0,
    study: 0
  };

  notes.forEach(note => {
    counts[note.category]++;
  });

  return counts;
}

function getSummary() {
    let counts = countByCategory();

    return '&{notes.lenght} notes: &{counts.personal} personal, &{counts.work} work, &{counts.study} study.';
}

function isDuplicate(text) {
  let cleanedText = text.trim().replace(/\s+/g, " ").toLowerCase();

  return notes.some(note => {
    let existingText = note.text.trim().replace(/\s+/g, " ").toLowerCase();

    return existingText === cleanedText;
  });
}

function addNote(text, category) {
  let cleanedText = text.trim();

  if (cleanedText.length < 1 || cleanedText.length > 200) {
    console.log("❌ Note must be between 1 and 200 characters.");
    return false;
  }

  if (isDuplicate(cleanedText)) {
    console.log("❌ This note already exists.");
    return false;
  }

  if (!["personal", "work", "study"].includes(category)) {
    console.log("❌ Category must be personal, work or study.");
    return false;
  }

  let newNote = {
    id: Date.now(),
    text: cleanedText,
    category: category
  };

  notes.push(newNote);

  console.log("✅ Note added successfully.");
  return true;
}

console.log("Search results:", searchNotes("day 3"));

console.log("Longest note:", longestNote());

console.log("Category counts:", countByCategory());

console.log("Summary:", getSummary());

console.log("Is 'Call mum' a duplicate?", isDuplicate("Call mum"));

console.log("Add valid note:", addNote("Learn JavaScript functions", "study"));

console.log("Try duplicate:", addNote("  CALL   MUM  ", "personal"));

console.log("Try invalid category:", addNote("Go shopping", "shopping"));

console.log("Try empty note:", addNote("   ", "personal"));

console.log("Final notes:", notes);

